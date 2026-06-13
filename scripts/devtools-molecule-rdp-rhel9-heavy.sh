#!/usr/bin/env bash
set -euo pipefail

echo "NOTE: scripts/devtools-molecule-rdp-rhel9-heavy.sh is deprecated." >&2
echo "NOTE: Use scripts/devtools-incus-selinux-heavy.sh instead." >&2

exec bash scripts/devtools-incus-selinux-heavy.sh
