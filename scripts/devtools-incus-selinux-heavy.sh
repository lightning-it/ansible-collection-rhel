#!/usr/bin/env bash
set -euo pipefail

RHEL_MAJOR_VERSION="${RHEL_MAJOR_VERSION:-10}"
INCUS_MODE="${INCUS_MODE:-vm}"
INCUS_INSTANCE_NAME="${INCUS_INSTANCE_NAME:-lit-rhel${RHEL_MAJOR_VERSION}-${INCUS_MODE}}"

case "${RHEL_MAJOR_VERSION}" in
  9|10)
    ;;
  *)
    echo "ERROR: Unsupported RHEL_MAJOR_VERSION=${RHEL_MAJOR_VERSION}. Supported values: 9, 10." >&2
    exit 2
    ;;
esac

case "${INCUS_MODE}" in
  vm|container)
    ;;
  *)
    echo "ERROR: Unsupported INCUS_MODE=${INCUS_MODE}. Supported values: vm, container." >&2
    exit 2
    ;;
esac

if ! command -v incus >/dev/null 2>&1; then
  echo "NOTE: incus is not installed. Skipping Incus SELinux heavy scenario."
  exit 9
fi

cleanup() {
  deploy/incus/scripts/destroy.sh --name "${INCUS_INSTANCE_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

deploy/incus/scripts/create.sh \
  --version "${RHEL_MAJOR_VERSION}" \
  --mode "${INCUS_MODE}" \
  --name "${INCUS_INSTANCE_NAME}"

inventory="deploy/incus/generated/${INCUS_INSTANCE_NAME}.ini"

ANSIBLE_COLLECTIONS_PATH="${PWD}:${PWD}/collections:${ANSIBLE_COLLECTIONS_PATH:-}" \
ANSIBLE_ROLES_PATH="${PWD}/roles:${ANSIBLE_ROLES_PATH:-}" \
ansible-playbook -i "${inventory}" playbooks/selinux.yml
