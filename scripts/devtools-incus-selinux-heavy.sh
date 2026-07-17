#!/usr/bin/env bash
set -euo pipefail

export MOLECULE_RUN_PROTECTED=true
export INCUS_MODE="${INCUS_MODE:-vm}"

exec bash scripts/devtools-molecule.sh selinux_rhel9_heavy
