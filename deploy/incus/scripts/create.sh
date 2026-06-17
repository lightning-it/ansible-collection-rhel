#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
incus_dir="$(cd "${script_dir}/.." && pwd)"
generated_dir="${incus_dir}/generated"

usage() {
  cat <<'EOF'
Usage: deploy/incus/scripts/create.sh [options]

Options:
  --version 9|10          Target RHEL major version. Default: 10.
  --mode vm|container     Incus launch mode. Default: vm.
  --name NAME             Incus instance name. Default: lit-rhel<VERSION>-<MODE>.
  --image ALIAS           Incus image alias. Overrides INCUS_RHEL9_IMAGE/INCUS_RHEL10_IMAGE.
  --profile-name NAME     Incus profile name. Default: <instance>-profile.
  --ssh-user USER         Cloud-init SSH user. Default: ansible.
  --public-key-file PATH  SSH public key file. Default: first existing id_ed25519.pub/id_rsa.pub.
  --public-key KEY        SSH public key content. Overrides --public-key-file.
  -h, --help              Show this help.

Environment overrides:
  INCUS_RHEL9_IMAGE       Default: images:rockylinux/9/cloud
  INCUS_RHEL10_IMAGE      Default: images:rockylinux/10/cloud
  INCUS_SSH_PRIVATE_KEY   Private key path written into generated inventory.
EOF
}

version="${INCUS_RHEL_MAJOR_VERSION:-10}"
mode="${INCUS_MODE:-vm}"
instance_name=""
image_alias=""
profile_name=""
ssh_user="${INCUS_SSH_USER:-ansible}"
public_key_file="${INCUS_SSH_PUBLIC_KEY_FILE:-}"
public_key_content="${INCUS_SSH_PUBLIC_KEY:-}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      version="${2:?--version requires a value}"
      shift 2
      ;;
    --mode)
      mode="${2:?--mode requires a value}"
      shift 2
      ;;
    --name)
      instance_name="${2:?--name requires a value}"
      shift 2
      ;;
    --image)
      image_alias="${2:?--image requires a value}"
      shift 2
      ;;
    --profile-name)
      profile_name="${2:?--profile-name requires a value}"
      shift 2
      ;;
    --ssh-user)
      ssh_user="${2:?--ssh-user requires a value}"
      shift 2
      ;;
    --public-key-file)
      public_key_file="${2:?--public-key-file requires a value}"
      shift 2
      ;;
    --public-key)
      public_key_content="${2:?--public-key requires a value}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "${version}" in
  9|10)
    ;;
  *)
    echo "ERROR: Unsupported RHEL major version '${version}'. Supported values: 9, 10." >&2
    exit 2
    ;;
esac

case "${mode}" in
  vm|container)
    ;;
  *)
    echo "ERROR: Unsupported Incus mode '${mode}'. Supported values: vm, container." >&2
    exit 2
    ;;
esac

if ! command -v incus >/dev/null 2>&1; then
  echo "ERROR: incus command not found. Install and initialize Incus first." >&2
  exit 127
fi

if [ -z "${image_alias}" ]; then
  if [ "${version}" = "9" ]; then
    image_alias="${INCUS_RHEL9_IMAGE:-images:rockylinux/9/cloud}"
  else
    image_alias="${INCUS_RHEL10_IMAGE:-images:rockylinux/10/cloud}"
  fi
fi

if [ -z "${instance_name}" ]; then
  instance_name="lit-rhel${version}-${mode}"
fi

if [ -z "${profile_name}" ]; then
  profile_name="${instance_name}-profile"
fi

if [ -z "${public_key_content}" ]; then
  if [ -z "${public_key_file}" ]; then
    for candidate in "${HOME}/.ssh/id_ed25519.pub" "${HOME}/.ssh/id_rsa.pub"; do
      if [ -f "${candidate}" ]; then
        public_key_file="${candidate}"
        break
      fi
    done
  fi

  if [ -z "${public_key_file}" ] || [ ! -f "${public_key_file}" ]; then
    echo "ERROR: No SSH public key found. Use --public-key-file or --public-key." >&2
    exit 2
  fi

  public_key_content="$(tr -d '\n' < "${public_key_file}")"
fi

if [ -z "${INCUS_SSH_PRIVATE_KEY:-}" ] && [ -n "${public_key_file}" ]; then
  ssh_private_key="${public_key_file%.pub}"
else
  ssh_private_key="${INCUS_SSH_PRIVATE_KEY:-${HOME}/.ssh/id_ed25519}"
fi

cloud_init_template="${incus_dir}/cloud-init/rhel${version}.cloud-config"
profile_template="${incus_dir}/profiles/rhel${version}-${mode}.yml"

if [ ! -f "${cloud_init_template}" ] || [ ! -f "${profile_template}" ]; then
  echo "ERROR: Missing Incus template for RHEL ${version} ${mode}." >&2
  exit 1
fi

mkdir -p "${generated_dir}"

cloud_init_file="${generated_dir}/${instance_name}-cloud-init.yml"
profile_file="${generated_dir}/${profile_name}.yml"
inventory_file="${generated_dir}/${instance_name}.ini"
env_file="${generated_dir}/${instance_name}.env"

while IFS= read -r line || [ -n "${line}" ]; do
  line="${line//@@SSH_USER@@/${ssh_user}}"
  line="${line//@@SSH_PUBLIC_KEY@@/${public_key_content}}"
  printf '%s\n' "${line}"
done < "${cloud_init_template}" > "${cloud_init_file}"

awk '
  FNR == NR {
    user_data = user_data "    " $0 "\n"
    next
  }
  /@@CLOUD_INIT_USER_DATA@@/ {
    printf "%s", user_data
    next
  }
  { print }
' "${cloud_init_file}" "${profile_template}" > "${profile_file}"

if incus info "${instance_name}" >/dev/null 2>&1; then
  echo "ERROR: Incus instance '${instance_name}' already exists. Destroy it first or choose --name." >&2
  exit 2
fi

if incus profile show "${profile_name}" >/dev/null 2>&1; then
  incus profile delete "${profile_name}"
fi

incus profile create "${profile_name}" >/dev/null
incus profile edit "${profile_name}" < "${profile_file}"

if [ "${mode}" = "vm" ]; then
  incus init "${image_alias}" "${instance_name}" --profile default --profile "${profile_name}" --vm
  incus config device add "${instance_name}" cloud-init disk source=cloud-init:config
  incus start "${instance_name}"
else
  incus launch "${image_alias}" "${instance_name}" --profile default --profile "${profile_name}"
fi

cat > "${env_file}" <<EOF
INCUS_INSTANCE_NAME=${instance_name}
INCUS_PROFILE_NAME=${profile_name}
INCUS_RHEL_MAJOR_VERSION=${version}
INCUS_MODE=${mode}
INCUS_IMAGE=${image_alias}
INCUS_SSH_USER=${ssh_user}
INCUS_SSH_PRIVATE_KEY=${ssh_private_key}
INCUS_INVENTORY=${inventory_file}
EOF

inventory_ready=false
for _attempt in $(seq 1 120); do
  if "${script_dir}/inventory.sh" \
    --name "${instance_name}" \
    --user "${ssh_user}" \
    --private-key "${ssh_private_key}" > "${inventory_file}.tmp" 2>/dev/null; then
    mv "${inventory_file}.tmp" "${inventory_file}"
    inventory_ready=true
    break
  fi
  sleep 2
done

rm -f "${inventory_file}.tmp"

if [ "${inventory_ready}" != "true" ]; then
  echo "ERROR: Timed out waiting for an IPv4 address on '${instance_name}'." >&2
  exit 1
fi

cat <<EOF
Created Incus ${mode}: ${instance_name}
RHEL major version: ${version}
Image alias: ${image_alias}
Profile: ${profile_name}
Inventory: ${inventory_file}

Next:
  ansible-playbook -i ${inventory_file} playbooks/selinux.yml
EOF
