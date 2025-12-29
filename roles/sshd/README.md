# SSHD Role

Configure and manage the SSH daemon on RHEL hosts.

## Variables

- `rhel_sshd_manage_service`: whether to enable/start sshd (default: `true`)
- `rhel_sshd_port`: SSH listening port (default: `22`)
- `rhel_sshd_permit_root_login`: value for `PermitRootLogin` (default: `no`)
- `rhel_sshd_password_authentication`: value for `PasswordAuthentication` (default: `no`)
- `rhel_sshd_challenge_response_authentication`: value for `ChallengeResponseAuthentication` (default: `no`)
- `rhel_sshd_allow_users`: list of users allowed (renders `AllowUsers`, default: `[]`)
- `rhel_sshd_allow_groups`: list of groups allowed (renders `AllowGroups`, default: `[]`)
- `rhel_sshd_deny_users`: list of users denied (renders `DenyUsers`, default: `[]`)
- `rhel_sshd_deny_groups`: list of groups denied (renders `DenyGroups`, default: `[]`)
- `rhel_sshd_extra_options`: map of additional sshd_config key/value pairs (default: `{}`)

## Example

```yaml
- hosts: all
  become: true

  roles:
    - role: lit.rhel.sshd
      vars:
        rhel_sshd_port: 2222
        rhel_sshd_allow_users: ["ops-admin"]
        rhel_sshd_password_authentication: "no"
        rhel_sshd_extra_options:
          ClientAliveInterval: 300
          ClientAliveCountMax: 2
```
