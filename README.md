# ansible-collection-rhel

<!-- BEGIN LIT_QUALITY_BADGES -->

[![CI](https://github.com/lightning-it/ansible-collection-rhel/actions/workflows/collection-ci.yml/badge.svg?branch=develop)](https://github.com/lightning-it/ansible-collection-rhel/actions/workflows/collection-ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/lightning-it/ansible-collection-rhel?sort=semver)](https://github.com/lightning-it/ansible-collection-rhel/releases/latest)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/lightning-it/ansible-collection-rhel/badge)](https://scorecard.dev/viewer/?uri=github.com/lightning-it/ansible-collection-rhel)
[![Ansible Galaxy](https://img.shields.io/ansible/collection/v/lit/rhel?label=Ansible%20Galaxy)](https://galaxy.ansible.com/ui/repo/published/lit/rhel/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

<!-- END LIT_QUALITY_BADGES -->

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

## Security

See [SECURITY.md](./SECURITY.md) for supported versions and vulnerability reporting.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution and review expectations.

## License

See [LICENSE](./LICENSE).

<!-- BEGIN LIT_RELEASE_QUALITY_MODEL -->

## Release and Quality Model

This repository follows the Lightning IT shared release and quality model.
The README shows the current supported and tested matrix.
Exact per-version validation proof is stored with each GitHub Release as `release-evidence.md` and `release-evidence.json`.
Releases are created from the protected `main` branch after a reviewed `develop -> main` release promotion.
Collection releases validate collection sanity, Molecule scenarios, build integrity, and Ansible Galaxy publishing where enabled.

See:

- [RELEASE.md](./RELEASE.md)
- [TESTING.md](./TESTING.md)
- [GitHub Releases](../../releases)

Repository classification: **Ansible Collection**.
Required test profiles: `pre-commit, lint, light, molecule-light, molecule-heavy-incus, release-validation`.
Publishing targets: `github-release, ansible-galaxy`.

<!-- END LIT_RELEASE_QUALITY_MODEL -->

<!-- BEGIN LIT_COMPATIBILITY_MATRIX -->

## Compatibility Matrix

| Collection Version | Platform | Product | Validation |
|---|---|---|---|
| Latest release | ubuntu-latest | ansible-core, molecule, incus | See release evidence |
| Latest release | rhel-9 | ansible-core, molecule, incus | See release evidence |
| Latest release | rhel-10 | ansible-core, molecule, incus | See release evidence |

| Scenario | Test Type | Validation |
|---|---|---|
| collection-sanity | Collection sanity | See release evidence |
| molecule-light | Molecule light | See release evidence |
| molecule-heavy-incus | Heavy Incus | See release evidence |
| galaxy-build | Galaxy build/publish | See release evidence |

Validation proof for each released version is stored in the corresponding GitHub Release evidence.

<!-- END LIT_COMPATIBILITY_MATRIX -->

## Release Evidence

Every released version includes immutable release evidence attached to the corresponding GitHub Release.
The evidence records:

- tested matrix combinations
- GitHub Actions run links
- artifact references
- publish status
- security scan status

See [GitHub Releases](../../releases), [RELEASE.md](./RELEASE.md), and [TESTING.md](./TESTING.md) for the release process and validation model.
