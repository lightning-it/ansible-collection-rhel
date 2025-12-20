#!/usr/bin/env bash
set -eo pipefail

# 1) Namespace with default
COLLECTION_NAMESPACE="${COLLECTION_NAMESPACE:-lit}"

# 2) Derive COLLECTION_NAME from repo name if not set
if [ -z "${COLLECTION_NAME:-}" ]; then
  # Prefer GITHUB_REPOSITORY in CI (org/repo)
  if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    repo_basename="${GITHUB_REPOSITORY##*/}"
  else
    # Fallback: current directory name
    repo_basename="$(basename "$PWD")"
  fi

  case "$repo_basename" in
    ansible-collection-*)
      COLLECTION_NAME="${repo_basename#ansible-collection-}"
      ;;
    *)
      echo "WARN: Could not infer COLLECTION_NAME from repo name '${repo_basename}', falling back to 'foundational'" >&2
      COLLECTION_NAME="foundational"
      ;;
  esac
fi

echo "Preparing Molecule tests for collection: ${COLLECTION_NAMESPACE}.${COLLECTION_NAME}"

# 3) Run inside wunder-devtools-ee
COLLECTION_NAMESPACE="$COLLECTION_NAMESPACE" \
COLLECTION_NAME="$COLLECTION_NAME" \
bash scripts/wunder-devtools-ee.sh bash -lc '
  set -e

  ns="${COLLECTION_NAMESPACE}"
  name="${COLLECTION_NAME}"

  echo "Preparing collection ${ns}.${name} for Molecule tests..."

  # 1) Clean potentially stale dependency installs *before* we build/install.
  dep_paths=()
  dep_fqcns=()
  if [ -f /workspace/galaxy.yml ]; then
    while IFS= read -r line; do
      dep_paths+=("${line%::*}")
      dep_fqcns+=("${line##*::}")
    done < <(
      python3 - <<'PY'
import yaml, sys
try:
    with open("/workspace/galaxy.yml", "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    for fqcn in (data.get("dependencies") or {}).keys():
        parts = fqcn.split(".")
        if len(parts) == 2:
            ns, name = parts
            path = f"/tmp/wunder/collections/ansible_collections/{ns}/{name}"
            print(f"{path}::{fqcn}")
except Exception as exc:  # noqa: BLE001
    sys.stderr.write(f"WARN: failed to parse galaxy.yml dependencies: {exc}\n")
PY
    )
  fi

  for dep_path in "${dep_paths[@]}"; do
    if [ -d "$dep_path" ]; then
      echo "Removing stale dependency at $dep_path to allow a clean install..."
      rm -rf "$dep_path" || true
    fi
  done

  # 2) Build + install collection into /tmp/wunder/collections
  /workspace/scripts/devtools-collection-prepare.sh

  # 2b) Install declared dependencies freshly (if any)
  for dep_fqcn in "${dep_fqcns[@]}"; do
    if [ -n "$dep_fqcn" ]; then
      echo "Installing dependency ${dep_fqcn} into /tmp/wunder/collections..."
      ansible-galaxy collection install "$dep_fqcn" -p /tmp/wunder/collections --force
    fi
  done

  # 3) Configure Ansible environment for Molecule
  export ANSIBLE_COLLECTIONS_PATHS=/tmp/wunder/collections

  if [ -f /workspace/ansible.cfg ]; then
    export ANSIBLE_CONFIG=/workspace/ansible.cfg
  fi

  export MOLECULE_NO_LOG="${MOLECULE_NO_LOG:-false}"
  export DOCKER_HOST="${DOCKER_HOST:-unix:///var/run/docker.sock}"

  # 3) Discover non-heavy scenarios and run molecule test -s ...
  scenarios=()
  if [ -d molecule ]; then
    for d in molecule/*; do
      if [ -d "$d" ] && [ -f "$d/molecule.yml" ]; then
        scen="$(basename "$d")"
        case "$scen" in
          *_heavy)
            echo "Skipping heavy scenario '${scen}' in devtools-molecule.sh (run manually via dedicated script)."
            continue
            ;;
        esac
        scenarios+=("$scen")
      fi
    done
  fi

  if [ "${#scenarios[@]}" -eq 0 ]; then
    echo "No non-heavy Molecule scenarios found - skipping Molecule tests."
    exit 0
  fi

  echo "Running Molecule scenarios: ${scenarios[*]}"

  for scen in "${scenarios[@]}"; do
    echo ">>> molecule test -s ${scen}"
    molecule test -s "${scen}"
  done
'
