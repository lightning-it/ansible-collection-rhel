#!/usr/bin/env bash
set -euo pipefail

# This script runs an RHEL9 Vagrant VM and executes the rdp-rhel9 Molecule
# scenario inside the wunder-devtools-ee container.
#
# It is intended as a **manual** heavy-weight scenario:
# - requires Vagrant
# - requires a working provider (e.g. VirtualBox/VMware/libvirt)
#
# If Vagrant or a provider is missing, we print a note and exit with 9 to
# signal "skipped" to callers (pre-commit, CI).

# If Parallels was requested but prlctl is missing, drop it so we can fall back
if [ "${VAGRANT_DEFAULT_PROVIDER:-}" = "parallels" ] && ! command -v prlctl >/dev/null 2>&1; then
  echo "NOTE: VAGRANT_DEFAULT_PROVIDER=parallels but 'prlctl' not found; falling back to auto-detect."
  unset VAGRANT_DEFAULT_PROVIDER
fi

# Auto-detect provider if none was chosen:
# 1) qemu plugin (common for Apple Silicon)
# 2) VirtualBox
# 3) Parallels (if available)
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
  # Default to an ARM-capable RHEL9-compatible box for Parallels on Apple Silicon.
  # Override via VAGRANT_BOX if you have your own image.
  export VAGRANT_BOX="${VAGRANT_BOX:-generic/rhel9}"
fi

if [ "${VAGRANT_DEFAULT_PROVIDER:-}" = "qemu" ] && [ "$(uname -m)" = "arm64" ]; then
  # Suggest an ARM-capable box for qemu; override if you have a preferred image.
  export VAGRANT_BOX="${VAGRANT_BOX:-generic/rhel9}"
fi

# 0) Check if vagrant is available at all
if ! command -v vagrant >/dev/null 2>&1; then
  echo "NOTE: vagrant is not installed. Skipping rdp-rhel9 scenario."
  exit 9
fi

# 1) VM start (but first check provider availability)
pushd vagrant/rhel9 >/dev/null

# Capture provider errors (e.g. Parallels Standard edition lacks CLI)
status_out="$(vagrant status 2>&1 || true)"
if echo "${status_out}" | grep -qi "could not be found, but was requested"; then
  # Stale provider metadata in .vagrant – try a clean slate
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
  echo "Tip: Parallels requires Pro/Business edition for vagrant; otherwise use"
  echo "     another provider (VirtualBox/VMware/libvirt) or set VAGRANT_DEFAULT_PROVIDER."
  popd >/dev/null
  exit 9
fi

# Try to bring up the VM; if box is missing (e.g. ARM box not found), skip
if ! vagrant up; then
  echo "NOTE: Failed to bring up the VM."
  echo "      - If you're on Apple Silicon with Parallels, set VAGRANT_BOX to an ARM-capable box you trust."
  echo "      - If a VM with the same name already exists in Parallels/QEMU, set VAGRANT_VM_NAME to a unique name"
  echo "        or remove the old VM, then retry."
  popd >/dev/null
  exit 9
fi
popd >/dev/null

# 2) Molecule (inside wunder-devtools-ee)
scenario_dir="molecule/rdp-rhel9"
if [ ! -f "${scenario_dir}/molecule.yml" ]; then
  echo "NOTE: Molecule scenario '${scenario_dir}' not found. Skipping."
  # Clean up the VM we just created
  pushd vagrant/rhel9 >/dev/null
  vagrant destroy -f
  popd >/dev/null
  exit 9
fi

ANSIBLE_COLLECTIONS_PATHS="$PWD" \
ANSIBLE_ROLES_PATH="$PWD/roles" \
bash scripts/wunder-devtools-ee.sh \
  molecule test -s rdp-rhel9

# 3) VM destroy
pushd vagrant/rhel9 >/dev/null
vagrant destroy -f
popd >/dev/null
