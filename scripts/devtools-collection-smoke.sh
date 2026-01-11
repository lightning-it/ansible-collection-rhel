#!/usr/bin/env bash
set -eo pipefail

COLLECTION_NAMESPACE="${COLLECTION_NAMESPACE:-lit}"

if [ -z "${COLLECTION_NAME:-}" ]; then
  if [ -f galaxy.yml ]; then
    COLLECTION_NAME="$(python3 - <<'PY'
import yaml
with open("galaxy.yml", "r", encoding="utf-8") as f:
    data = yaml.safe_load(f) or {}
print(data.get("name", ""))
PY
)"
  fi
  if [ -z "${COLLECTION_NAME:-}" ]; then
    echo "ERROR: COLLECTION_NAME not set and galaxy.yml missing 'name'." >&2
    exit 1
  fi
fi

EXAMPLE_PLAYBOOK="${EXAMPLE_PLAYBOOK:-playbooks/example.yml}"

echo "Running collection smoke test for ${COLLECTION_NAMESPACE}.${COLLECTION_NAME} using ${EXAMPLE_PLAYBOOK}"

COLLECTION_NAMESPACE="$COLLECTION_NAMESPACE" \
COLLECTION_NAME="$COLLECTION_NAME" \
EXAMPLE_PLAYBOOK="$EXAMPLE_PLAYBOOK" \
bash scripts/wunder-devtools-ee.sh bash -lc '
  set -euo pipefail

  ns="${COLLECTION_NAMESPACE}"
  name="${COLLECTION_NAME}"
  example="${EXAMPLE_PLAYBOOK:-playbooks/example.yml}"

  echo "Running collection smoke test for ${ns}.${name} with example playbook: ${example}"

  # -------------------------------------------------------------------
  # 1) Build + install this collection into a per-run collections dir
  # -------------------------------------------------------------------
  COLLECTIONS_DIR="$(/workspace/scripts/devtools-collection-prepare.sh | tail -n 1)"

  if [ -z "${COLLECTIONS_DIR:-}" ] || [ ! -d "${COLLECTIONS_DIR}" ]; then
    echo "ERROR: COLLECTIONS_DIR not found/invalid: ${COLLECTIONS_DIR:-<empty>}" >&2
    exit 1
  fi

  export ANSIBLE_COLLECTIONS_PATH="${COLLECTIONS_DIR}:/usr/share/ansible/collections"

  # -------------------------------------------------------------------
  # 2) Install declared dependencies into the SAME per-run dir
  # -------------------------------------------------------------------
  dep_fqcns=()
  if [ -f /workspace/galaxy.yml ]; then
    while IFS= read -r fqcn; do
      dep_fqcns+=("$fqcn")
    done < <(
      python3 - <<'"PY"'
import yaml, sys, os
try:
    with open("/workspace/galaxy.yml", "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    deps = data.get("dependencies") or {}
    for fqcn in deps.keys():
        print(fqcn)
except Exception as exc:  # noqa: BLE001
    sys.stderr.write(f"WARN: failed to parse galaxy.yml dependencies: {exc}\n")
PY
    )
  fi

  for dep_fqcn in "${dep_fqcns[@]}"; do
    if [ -n "$dep_fqcn" ]; then
      ns_part="${dep_fqcn%%.*}"
      name_part="${dep_fqcn#*.}"
      target_path="${COLLECTIONS_DIR}/ansible_collections/${ns_part}/${name_part}"
      bundled_path="/workspace/collections/ansible_collections/${ns_part}/${name_part}"

      if [ -d "${target_path}" ]; then
        echo "Dependency ${dep_fqcn} already present in ${COLLECTIONS_DIR}, skipping."
        continue
      fi

      if [ -d "${bundled_path}" ]; then
        echo "Installing dependency ${dep_fqcn} from bundled path ${bundled_path}..."
        ansible-galaxy collection install "${bundled_path}" -p "${COLLECTIONS_DIR}" --force --offline
      else
        echo "Installing dependency ${dep_fqcn} into ${COLLECTIONS_DIR} (online fallback)..."
        ansible-galaxy collection install "$dep_fqcn" -p "${COLLECTIONS_DIR}" --force
      fi
    fi
  done

  # -------------------------------------------------------------------
  # 3) Configure Ansible (optional)
  # -------------------------------------------------------------------
  if [ -f /workspace/ansible.cfg ]; then
    export ANSIBLE_CONFIG=/workspace/ansible.cfg
  fi

  # -------------------------------------------------------------------
  # 4) Run example playbook
  # -------------------------------------------------------------------
  ansible-playbook -i localhost, "${example}"
'
