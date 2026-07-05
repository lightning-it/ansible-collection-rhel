# ansible-collection-rhel

<!-- BEGIN LIT_QUALITY_BADGES -->

[![CI](https://github.com/lightning-it/ansible-collection-rhel/actions/workflows/collection-ci.yml/badge.svg?branch=develop)](https://github.com/lightning-it/ansible-collection-rhel/actions/workflows/collection-ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/lightning-it/ansible-collection-rhel?sort=semver)](https://github.com/lightning-it/ansible-collection-rhel/releases/latest)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/lightning-it/ansible-collection-rhel/badge)](https://scorecard.dev/viewer/?uri=github.com/lightning-it/ansible-collection-rhel)
[![Ansible Galaxy](https://img.shields.io/ansible/collection/v/lit/rhel?label=Ansible%20Galaxy)](https://galaxy.ansible.com/ui/repo/published/lit/rhel/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

<!-- END LIT_QUALITY_BADGES -->

<!-- BEGIN LIT_SHARED_RELEASE_MODEL -->

## Release and Quality Model

This repository follows the Lightning IT shared release and quality model.

See [RELEASE.md](./RELEASE.md) for:

- branch and release flow
- required quality checks
- test matrix
- release evidence
- artifact publishing
- supported repository-specific release behavior

Repository classification: **Ansible Collection**.
Required test profiles: `pre-commit, lint, light, molecule-light, molecule-heavy-incus, release-validation`.
Publishing targets: `github-release, ansible-galaxy`.

## Supported and Tested Platforms

| Platform / Product | Status | Validation |
|---|---:|---|
| ubuntu-latest | Supported | Molecule / Incus |
| rhel-9 | Supported | Molecule / Incus |
| rhel-10 | Supported | Molecule / Incus |
| ansible-core | Tested where applicable | Molecule / Incus |
| molecule | Tested where applicable | Molecule / Incus |
| incus | Tested where applicable | Molecule / Incus |

<!-- END LIT_SHARED_RELEASE_MODEL -->

RHEL-focused Ansible collection covering OS baseline, security, users, packages,
and day-2 operational tasks for Red Hat Enterprise Linux.

This collection is part of the ModuLix / Lightning IT ecosystem and provides
reusable roles to standardise RHEL hosts across environments (lab, demo,
nightly, prod).

## Roles

Planned and initial roles include:

- `lit.rhel.selinux`  
  Manage SELinux policy and mode (enforcing/permissive/disabled) in an
  idempotent way, using `ansible.posix.selinux`.
- `lit.rhel.automatic_updates`
  Schedule weekly OS updates via cron (dnf/yum) with configurable timing and
  logging.
- `lit.rhel.rhsm`
  Register or unregister RHEL systems with RHSM or Satellite.
- `lit.rhel.repos`
  Enable RHEL repository sources such as RHSM-managed repositories, CodeReady,
  custom repos, and EPEL policy.
- `lit.rhel.cloud_image`
  Build reusable unregistered RHEL qcow2 cloud image artifacts for later
  hypervisor import.
- `lit.rhel.virtual_guest`
  Configure reusable RHEL virtual machine guest baseline packages and services.

Further roles (baseline, users, patching, etc.) will be added over time.

## Example

A minimal example playbook using the SELinux role:

```yaml
---
- name: Configure SELinux on RHEL hosts
  hosts: rhel
  become: true

  roles:
    - role: lit.rhel.selinux
      vars:
        rhel_selinux_state: enforcing
        rhel_selinux_policy: targeted
```

## Development

This repository is designed to be used together with:

- `pre-commit` for local linting,
- the shared `wunder-devtools-ee` container for consistent tooling,
- Molecule scenarios for role-level testing and an Incus-backed local deployment
  workflow under `deploy/incus/` for RHEL-family VM/container testing. The Incus
  workflow defaults to RHEL major version 10 and keeps RHEL 9 selectable.

Each role is expected to provide:

- `meta/main.yml` with Galaxy metadata,
- `defaults/main.yml` with well-documented variables,
- `README.md` with a clear description and examples.

## Local Incus Testing

Create a default RHEL 10-compatible Incus VM:

```bash
deploy/incus/scripts/create.sh
```

Create a RHEL 9-compatible Incus VM:

```bash
deploy/incus/scripts/create.sh --version 9 --mode vm --name lit-rhel9-vm
```

Create a RHEL-compatible Incus container:

```bash
deploy/incus/scripts/create.sh --version 10 --mode container --name lit-rhel10-container
```

Run a playbook against the generated inventory:

```bash
ansible-playbook -i deploy/incus/generated/lit-rhel10-vm.ini playbooks/selinux.yml
```

Destroy the VM:

```bash
deploy/incus/scripts/destroy.sh --name lit-rhel10-vm
```

Actual RHEL images should be preloaded as private Incus aliases such as
`local:rhel10-ci` or selected with `INCUS_RHEL10_IMAGE` / `INCUS_RHEL9_IMAGE`.
The public defaults use RHEL-compatible community images and do not require Red
Hat credentials.
