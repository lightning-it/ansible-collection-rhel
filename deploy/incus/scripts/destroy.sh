#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
incus_dir="$(cd "${script_dir}/.." && pwd)"
generated_dir="${incus_dir}/generated"

usage() {
  cat <<'EOF'
Usage: deploy/incus/scripts/destroy.sh [options]

Options:
  --name NAME          Incus instance name. Default: INCUS_INSTANCE_NAME or lit-rhel10-vm.
  --profile-name NAME  Incus profile name. Default: <instance>-profile.
  -h, --help           Show this help.
EOF
}

instance_name="${INCUS_INSTANCE_NAME:-lit-rhel10-vm}"
profile_name="${INCUS_PROFILE_NAME:-}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name)
      instance_name="${2:?--name requires a value}"
      shift 2
      ;;
    --profile-name)
      profile_name="${2:?--profile-name requires a value}"
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

if [ -z "${profile_name}" ]; then
  profile_name="${instance_name}-profile"
fi

if ! command -v incus >/dev/null 2>&1; then
  echo "ERROR: incus command not found. Install and initialize Incus first." >&2
  exit 127
fi

if incus info "${instance_name}" >/dev/null 2>&1; then
  incus delete "${instance_name}" --force
fi

if incus profile show "${profile_name}" >/dev/null 2>&1; then
  incus profile delete "${profile_name}"
fi

rm -f \
  "${generated_dir}/${instance_name}.ini" \
  "${generated_dir}/${instance_name}.env" \
  "${generated_dir}/${instance_name}-cloud-init.yml" \
  "${generated_dir}/${profile_name}.yml"

echo "Destroyed Incus instance '${instance_name}' and profile '${profile_name}'."
