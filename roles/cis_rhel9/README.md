# CIS RHEL9 Role

Thin wrapper around `ansible-lockdown.rhel9_cis`.

## Requirements

The execution environment must install `ansible-lockdown.rhel9_cis` as a Galaxy role.

## Variables

Configure the upstream role through inventory variables such as `rhel9cis_level_1`,
`rhel9cis_level_2`, `rhel9cis_disruption_high`, `run_audit`, and `audit_only`.

## Dependencies

External Galaxy role: `ansible-lockdown.rhel9_cis`.

## Example Playbook

```yaml
---
- name: Use lit.rhel.cis_rhel9
  hosts: rhel9_cis_targets
  become: true
  roles:
    - role: lit.rhel.cis_rhel9
```

## License

MIT

## Author

Lightning IT
