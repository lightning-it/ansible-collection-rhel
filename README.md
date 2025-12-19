# ansible-collection-rhel

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

Further roles (baseline, users, firewalld, ssh_hardening, patching, etc.) will
be added over time.

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
- Molecule scenarios for role-level testing (e.g. `selinux_rhel9_heavy` via
  Vagrant-backed RHEL 9 instances).

Each role is expected to provide:

- `meta/main.yml` with Galaxy metadata,
- `defaults/main.yml` with well-documented variables,
- `README.md` with a clear description and examples.
