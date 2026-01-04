#!/usr/bin/env bash
set -euo pipefail

skip() {
  echo "Skipping firewalld_rhel9_heavy: $*"
  exit 0
}

# This script runs an RHEL9 Vagrant VM and executes the firewalld_rhel9_heavy Molecule
# scenario inside the wunder-devtools-ee container.
#
# It is intended as a **manual** heavy-weight scenario:
# - requires Vagrant
# - requires a working provider (e.g. qemu/VirtualBox/Parallels)
#
# If Vagrant or a provider is missing, we print a note and exit with 9 to
# signal "skipped" to callers (pre-commit, CI).

if [ "${VAGRANT_DEFAULT_PROVIDER:-}" = "parallels" ] && ! command -v prlctl >/dev/null 2>&1; then
  echo "NOTE: VAGRANT_DEFAULT_PROVIDER=parallels but 'prlctl' not found; falling back to auto-detect."
  unset VAGRANT_DEFAULT_PROVIDER
fi

# Auto-detect provider if none was chosen
if [ -z "${VAGRANT_DEFAULT_PROVIDER:-}" ]; then
  if command -v vagrant >/dev/null 2>&1 && vagrant plugin list 2>/dev/null | grep -qi "qemu"; then
    export VAGRANT_DEFAULT_PROVIDER="qemu"
  elif command -v VBoxManage >/dev/null 2>&1; then
    export VAGRANT_DEFAULT_PROVIDER="virtualbox"
  elif command -v prlctl >/dev/null 2>&1; then
    export VAGRANT_DEFAULT_PROVIDER="parallels"
  fi
fi

if [ "${VAGRANT_DEFAULT_PROVIDER:-}" = "parallels" ] && [ "$(uname -m)" = "arm64" ]; then
  export VAGRANT_BOX="${VAGRANT_BOX:-generic/rhel9}"
fi

if [ "${VAGRANT_DEFAULT_PROVIDER:-}" = "qemu" ] && [ "$(uname -m)" = "arm64" ]; then
  export VAGRANT_BOX="${VAGRANT_BOX:-generic/rhel9}"
fi

if ! command -v vagrant >/dev/null 2>&1; then
  echo "NOTE: vagrant is not installed. Skipping firewalld_rhel9_heavy scenario."
  skip "vagrant not installed"
fi

if [ ! -d vagrant/rhel9 ]; then
  echo "NOTE: Vagrant environment vagrant/rhel9 not found. Skipping firewalld_rhel9_heavy scenario."
  skip "vagrant env missing"
fi

if [ -z "${VAGRANT_SSH_PORT:-}" ]; then
  VAGRANT_SSH_PORT="$(python3 - <<'PY'
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(("127.0.0.1", 0))
port = s.getsockname()[1]
s.close()
print(port)
PY
)"
fi
export VAGRANT_SSH_PORT

pushd vagrant/rhel9 >/dev/null
rm -rf .vagrant

status_out="$(vagrant status 2>&1 || true)"
if echo "${status_out}" | grep -qi "could not be found, but was requested"; then
  if [ -d .vagrant ]; then
    echo "NOTE: Removing stale .vagrant provider metadata and retrying with ${VAGRANT_DEFAULT_PROVIDER:-auto}."
    rm -rf .vagrant
    status_out="$(vagrant status 2>&1 || true)"
  fi
fi

if echo "${status_out}" | grep -qi "could not be found, but was requested"; then
  echo "NOTE: Vagrant is installed, but the selected provider is not usable."
  echo "Provider error:"
  echo "${status_out}"
  echo "Detected providers on this host (best effort): ${VAGRANT_DEFAULT_PROVIDER:-<none>}"
  popd >/dev/null
  skip "provider unusable"
fi

if ! vagrant up; then
  echo "NOTE: Failed to bring up the VM."
  echo "      - If you're on Apple Silicon with Parallels, set VAGRANT_BOX to an ARM-capable box you trust."
  echo "      - If a VM with the same name already exists, set VAGRANT_VM_NAME to a unique name or remove the old VM, then retry."
  popd >/dev/null
  skip "vagrant up failed"
fi

ssh_cfg="$(vagrant ssh-config default 2>/dev/null || true)"
VAGRANT_SSH_HOST="host.docker.internal"
VAGRANT_SSH_PORT="$(echo "$ssh_cfg" | awk '/Port/ {print $2; exit}' )"
VAGRANT_SSH_USER="$(echo "$ssh_cfg" | awk '/User/ {print $2; exit}' )"
VAGRANT_SSH_KEY="/workspace/vagrant/rhel9/.vagrant/machines/default/qemu/private_key"
export VAGRANT_SSH_HOST VAGRANT_SSH_PORT VAGRANT_SSH_USER VAGRANT_SSH_KEY

popd >/dev/null

scenario_dir="molecule/firewalld_rhel9_heavy"
if [ ! -f "${scenario_dir}/molecule.yml" ]; then
  echo "NOTE: Molecule scenario '${scenario_dir}' not found. Skipping."
  pushd vagrant/rhel9 >/dev/null
  vagrant destroy -f
  popd >/dev/null
  skip "scenario missing"
fi

WUNDER_DEVTOOLS_RUN_AS_HOST_UID=0 \
ANSIBLE_COLLECTIONS_PATH="/tmp/wunder/collections" \
ANSIBLE_ROLES_PATH="/workspace/roles" \
VAGRANT_SSH_HOST="${VAGRANT_SSH_HOST:-127.0.0.1}" \
VAGRANT_SSH_PORT="${VAGRANT_SSH_PORT:-55222}" \
VAGRANT_SSH_USER="${VAGRANT_SSH_USER:-vagrant}" \
VAGRANT_SSH_KEY="${VAGRANT_SSH_KEY:-/workspace/vagrant/rhel9/.vagrant/machines/default/qemu/private_key}" \
ANSIBLE_SSH_ARGS="-o ControlMaster=no -o ControlPath=none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
bash scripts/wunder-devtools-ee.sh \
  molecule test -s firewalld_rhel9_heavy

pushd vagrant/rhel9 >/dev/null
vagrant destroy -f
popd >/dev/null
