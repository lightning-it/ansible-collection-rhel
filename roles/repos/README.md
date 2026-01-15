# lit.rhel.repos

Enable/prepare repository sources (CodeReady, EPEL, proxies).

- This role **only** enables repositories and refreshes metadata.
- It does **not** install service packages (those belong to service roles like `lit.rhel.xrdp`).

## Example (Workstations)
```yaml
- hosts: workstations
  become: true
  roles:
    - role: lit.rhel.repos
      vars:
        repos_enable_epel: true
        repos_enable_codeready: true
    - role: lit.rhel.gui
    - role: lit.rhel.xrdp
```

## Variables
- `repos_enable_codeready`: enable CodeReady Builder (default: `false`)
- `repos_codeready_repo`: repo id to enable (default: `codeready-builder-for-rhel-9-x86_64-rpms`)
- `repos_enable_epel`: enable EPEL (default: `false`)
- `repos_epel_method`: `rpm_url` or `package` (default: `rpm_url`)
- `repos_epel_rpm_url`: RPM URL for EPEL release (default: EPEL 9 release RPM)
- `repos_epel_package_name`: package name when using `package` method (default: `epel-release`)
- `repos_epel_gpg_key_url`: EPEL GPG key URL to import before install (default: EPEL 9 GPG key)
- `repos_makecache`: run `dnf -y makecache` (default: `true`)
