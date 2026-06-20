#!/usr/bin/env bash
set -euo pipefail

echo "NOTE: scripts/devtools-molecule-rdp-rhel9-heavy.sh is deprecated." >&2
echo "NOTE: Use MOLECULE_RUN_PROTECTED=true scripts/devtools-molecule.sh xrdp-rhel9 instead." >&2

export MOLECULE_RUN_PROTECTED=true
export INCUS_MODE="${INCUS_MODE:-vm}"

exec bash scripts/devtools-molecule.sh xrdp-rhel9
