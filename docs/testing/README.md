# Testing

This collection uses lightweight container-based Molecule scenarios for regular
local and public CI checks, and Incus VM scenarios for system-level behavior.

Incus VM scenarios are not run by the unfiltered `scripts/devtools-molecule.sh`
path because they require a host Incus daemon and trusted local images. Run them
explicitly by scenario name.

## Incus RHEL Images

Public examples use local aliases and do not require Red Hat credentials:

- `local:rhel9-ci`
- `local:rhel10-ci`

Override them when needed:

```bash
export INCUS_RHEL9_IMAGE=local:rhel9-ci
export INCUS_RHEL10_IMAGE=local:rhel10-ci
```

Private real-RHEL images must be preloaded on trusted local hosts or protected
self-hosted CI runners. Do not run private image workflows in public pull
request CI, and do not use `pull_request_target` for workflows that execute
repository code with access to secrets.

## Local Devtools Container

Incus workflow checks should run through the repo devtools wrapper so the
controller environment matches CI:

```bash
WUNDER_DEVTOOLS_LOCAL_CONTEXT=/Users/rene/sources/lit/NEW/container-wunder-devtools-ee \
WUNDER_DEVTOOLS_LOCAL_IMAGE=local/ee-wunder-devtools-ubi9:incus \
bash scripts/wunder-devtools-ee.sh incus --version
```

The wrapper forwards a detected host Incus socket into the container through
`INCUS_SOCKET`.

## XRDP

See `docs/testing/xrdp.md` for the Incus-backed XRDP scenarios and RDP
functional verification details.
