#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: deploy/incus/scripts/inventory.sh [options]

Options:
  --name NAME         Incus instance name. Default: INCUS_INSTANCE_NAME or lit-rhel10-vm.
  --user USER         SSH user. Default: INCUS_SSH_USER or ansible.
  --private-key PATH  SSH private key path. Default: INCUS_SSH_PRIVATE_KEY or ~/.ssh/id_ed25519.
  -h, --help          Show this help.
EOF
}

instance_name="${INCUS_INSTANCE_NAME:-lit-rhel10-vm}"
ssh_user="${INCUS_SSH_USER:-ansible}"
private_key="${INCUS_SSH_PRIVATE_KEY:-${HOME}/.ssh/id_ed25519}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name)
      instance_name="${2:?--name requires a value}"
      shift 2
      ;;
    --user)
      ssh_user="${2:?--user requires a value}"
      shift 2
      ;;
    --private-key)
      private_key="${2:?--private-key requires a value}"
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

if ! command -v incus >/dev/null 2>&1; then
  echo "ERROR: incus command not found. Install and initialize Incus first." >&2
  exit 127
fi

if ! incus info "${instance_name}" >/dev/null 2>&1; then
  echo "ERROR: Incus instance '${instance_name}' does not exist." >&2
  exit 2
fi

ip_address="$(
  incus list "${instance_name}" --format csv -c 46 |
    tr ',' '\n' |
    awk '/\([a-zA-Z0-9_.-]+\)$/ && $1 !~ /^fe80:/ {print $1; exit}'
)"

if [ -z "${ip_address}" ]; then
  echo "ERROR: Could not determine an IPv4 or non-link-local IPv6 address for '${instance_name}'." >&2
  exit 1
fi

cat <<EOF
[rhel_selinux_hosts]
${instance_name} ansible_host=${ip_address} ansible_user=${ssh_user} ansible_ssh_private_key_file=${private_key} ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[rhel:children]
rhel_selinux_hosts
EOF
