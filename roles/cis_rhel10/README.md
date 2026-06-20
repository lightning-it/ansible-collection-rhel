# CIS RHEL10 Role

Thin wrapper around `ansible-lockdown.rhel10_cis`.

## Requirements

The execution environment must install `ansible-lockdown.rhel10_cis` as a Galaxy role.

## Variables

Configure the upstream role through inventory variables such as `rhel10cis_level_1`,
`rhel10cis_level_2`, `rhel10cis_disruption_high`, `run_audit`, and `audit_only`.

## Dependencies

External Galaxy role: `ansible-lockdown.rhel10_cis`.

## Example Playbook

```yaml
---
- name: Use lit.rhel.cis_rhel10
  hosts: rhel10_cis_targets
  become: true
  roles:
    - role: lit.rhel.cis_rhel10
```

## License

MIT

## Author

Lightning IT
