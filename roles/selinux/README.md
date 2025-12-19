# lit.rhel.selinux

RHEL SELinux role for the `lit.rhel` collection. This role manages the system
SELinux mode and policy in an idempotent way, using the `ansible.posix.selinux`
module.

Typical use cases:

- Enforce SELinux on RHEL hosts (`enforcing` mode).
- Temporarily switch to `permissive` for troubleshooting.
- Ensure SELinux is not accidentally disabled.
- Standardise SELinux settings across environments.

## Variables

All variables are defined in `defaults/main.yml`.

```yaml
# Desired SELinux state: enforcing, permissive, or disabled
selinux_state: "enforcing"

# SELinux policy type: targeted or mls
selinux_policy: "targeted"

# Whether to manage /etc/selinux/config persistently
selinux_manage_config: true

# Whether to fail if SELinux is currently disabled in the kernel
# and cannot be enabled without a reboot.
selinux_fail_if_kernel_disabled: false
```

## Behaviour

- Uses `ansible.posix.selinux` to set SELinux mode and policy.
- If SELinux is disabled in the running kernel (`getenforce` → Disabled), the
  role will:
  - update `/etc/selinux/config` (if `selinux_manage_config: true`),
  - and either:
    - **warn** and continue if `selinux_fail_if_kernel_disabled: false`,
    - or **fail** with an explicit message if `true`.

## Example usage

```yaml
---
- name: Enforce SELinux on all RHEL hosts
  hosts: rhel
  become: true

  roles:
    - role: lit.rhel.selinux
      vars:
        selinux_state: enforcing
        selinux_policy: targeted
```

Example with permissive mode for a lab:

```yaml
---
- name: Set SELinux to permissive in lab
  hosts: lab
  become: true

  roles:
    - role: lit.rhel.selinux
      vars:
        selinux_state: permissive
```
