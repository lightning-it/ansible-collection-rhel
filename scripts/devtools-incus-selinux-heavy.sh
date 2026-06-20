#!/usr/bin/env bash
set -euo pipefail

export MOLECULE_RUN_PROTECTED=true
export INCUS_MODE="${INCUS_MODE:-vm}"

echo "Running selinux_rhel9_heavy with Incus mode: ${INCUS_MODE}" >&2
exec bash scripts/devtools-molecule.sh selinux_rhel9_heavy
