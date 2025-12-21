# lit.rhel.chrony

Manage chrony configuration on RHEL/EL systems.

## Variables

- `chrony_manage` (bool, default: `true`): Enable all chrony management tasks.
- `chrony_service_manage` (bool, default: `true`): Control the chronyd service (set `false` in containers without systemd).
- `chrony_packages` (list, default: `["chrony"]`): Packages to install.
- `chrony_pools` (list, default: `["pool.ntp.org iburst"]`): Pool entries to add.
- `chrony_servers` (list, default: `[]`): Server entries to add.
- `chrony_driftfile` (string, default: `/var/lib/chrony/drift`): Driftfile location.
- `chrony_makestep` (string, default: `"1.0 3"`): makestep directive value.

## Example

```yaml
- name: Configure chrony
  hosts: rhel
  become: true
  roles:
    - role: lit.rhel.chrony
      vars:
        chrony_manage: true
        chrony_service_manage: false  # set true on real systems with systemd
        chrony_pools:
          - "pool.ntp.org iburst"
```
