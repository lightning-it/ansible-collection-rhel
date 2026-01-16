# lit.rhel.xrdp

XRDP server role for RHEL 9.

## Repo policy
This role **never enables EPEL or any repository sources**.
Enable repositories via `lit.rhel.repos` (or your internal mirror policy).

## What it does
- Precheck: fails fast if xrdp packages are not available in enabled repos
- Installs XRDP packages
- Configures `/etc/xrdp/xrdp.ini` and `/etc/xrdp/startwm.sh`
- Optional TLS, SELinux label, firewalld port open
