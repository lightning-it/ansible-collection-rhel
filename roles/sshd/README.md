# SSHD Role

Configure and manage the SSH daemon on RHEL hosts.

## Variables

- `sshd_manage_service`: whether to enable/start sshd (default: `true`)
- `sshd_port`: SSH listening port (default: `22`)
- `sshd_permit_root_login`: value for `PermitRootLogin` (default: `no`)
- `sshd_password_authentication`: value for `PasswordAuthentication` (default: `no`)
- `sshd_challenge_response_authentication`: value for `ChallengeResponseAuthentication` (default: `no`)
- `sshd_allow_users`: list of users allowed (renders `AllowUsers`, default: `[]`)
- `sshd_allow_groups`: list of groups allowed (renders `AllowGroups`, default: `[]`)
- `sshd_deny_users`: list of users denied (renders `DenyUsers`, default: `[]`)
- `sshd_deny_groups`: list of groups denied (renders `DenyGroups`, default: `[]`)
- `sshd_extra_options`: map of additional sshd_config key/value pairs (default: `{}`)

## Example

```yaml
- hosts: all
  become: true

  roles:
    - role: lit.rhel.sshd
      vars:
        sshd_port: 2222
        sshd_allow_users: ["ops-admin"]
        sshd_password_authentication: "no"
        sshd_extra_options:
          ClientAliveInterval: 300
          ClientAliveCountMax: 2
```
