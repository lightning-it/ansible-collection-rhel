# lit.rhel.xrdp

Install and configure XRDP on RHEL 9 and RHEL 10.

This role does not enable EPEL, CodeReady Builder, CRB, Red Hat subscription
repositories, or internal mirrors. Repository policy belongs in inventory or in
`lit.rhel.repos`.

## Requirements

- Target OS family must be RedHat with major version `9` or `10`.
- Required XRDP packages must already be available from enabled repositories.
- A graphical session must be installed by the role or already present.

The role loads OS-specific variables from:

- `roles/xrdp/vars/RedHat-9.yml`
- `roles/xrdp/vars/RedHat-10.yml`

## Variables

Defaults live in `defaults/main.yml`. RHEL-version-specific package and service
facts live in `vars/RedHat-*.yml`.

Key variables:

- `xrdp_enabled`: Enable or skip the role. Default: `true`.
- `xrdp_listen_address`: Bind address. Default: `0.0.0.0`.
- `xrdp_listen_port`: RDP TCP port. Default: `3389`.
- `xrdp_service_manage`: Enable service management. Default: `true`.
- `xrdp_service_enabled`: Enable the service at boot. Default: `true`.
- `xrdp_service_state`: Runtime service state. Default: `started`.
- `xrdp_config_manage`: Manage `/etc/xrdp/xrdp.ini` and `startwm.sh`.
- `xrdp_firewalld_manage`: Manage firewalld port rule. Default: `true`.
- `xrdp_firewalld_zone`: Firewalld zone. Default: `public`.
- `xrdp_selinux_manage`: Manage SELinux TCP port label. Default: `true`.
- `xrdp_install_desktop`: Install graphical/session packages. Default: `false`.
- `xrdp_desktop`: Session selection, one of `auto`, `gnome`, `xfce`, `custom`.
- `xrdp_custom_startwm`: Shell content used when `xrdp_desktop: custom`.
- `xrdp_tls_enable`: Configure TLS certificate paths in `xrdp.ini`.
- `xrdp_tls_generate_self_signed`: Generate a self-signed certificate if missing.

The default `xrdp_firewalld_zone` is `public`. Earlier versions used `admin`,
which was environment-specific and is not present on a standard firewalld
installation.

## Dependencies

No role-specific collection dependencies beyond this collection's baseline
dependencies.

Package dependencies are OS-version-specific and defined in `vars/RedHat-9.yml`
and `vars/RedHat-10.yml`.

## Example Playbook

```yaml
---
- name: Install XRDP
  hosts: rhel_desktops
  become: true
  roles:
    - role: lit.rhel.xrdp
      vars:
        xrdp_install_desktop: true
        xrdp_desktop: gnome
        xrdp_firewalld_manage: true
        xrdp_listen_port: 3389
```

## License

MIT

## Author

Lightning IT
