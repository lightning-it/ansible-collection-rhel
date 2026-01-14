# lit.rhel.xrdp

XRDP server role for RHEL 9.

## What it does
- Installs XRDP packages
- Configures `/etc/xrdp/xrdp.ini` and `/etc/xrdp/startwm.sh`
- Optionally generates a self-signed TLS certificate for XRDP
- Optionally opens TCP/3389 in firewalld (zone configurable)
- Best-effort SELinux port labeling for TCP/3389

## Notes
- A desktop environment must exist for a useful RDP session.
- You can set `xrdp_install_desktop: true` to try installing GNOME (RHEL group). XFCE is best-effort and may require EPEL.

## Example
```yaml
- hosts: rhel_hosts
  become: true
  roles:
    - lit.rhel.xrdp
  vars:
    xrdp_firewalld_zone: admin
    xrdp_desktop: gnome
    xrdp_install_desktop: false
```
