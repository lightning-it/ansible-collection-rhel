# Baseline Role

Installs a minimal set of operational packages and configures timezone, locale, chrony, and optional sysctl defaults.

## Usage

```yaml
- hosts: all
  roles:
    - role: lit.rhel.baseline
      vars:
        baseline_packages_present:
          - vim
          - curl
        baseline_timezone: Europe/Berlin
        baseline_locale: en_US.UTF-8
        baseline_chrony_pools:
          - "pool.ntp.org iburst"
        baseline_sysctl:
          net.ipv4.ip_forward: 0
```

## Variables

- `baseline_packages_present`: list of packages to ensure are installed (default: `["curl", "vim", "jq", "tar", "bash-completion"]`)
- `baseline_timezone`: IANA timezone string configured via `community.general.timezone` (default: `Etc/UTC`, set empty to skip)
- `baseline_locale`: locale string written to `/etc/locale.conf` (default: `en_US.UTF-8`, set empty to skip)
- `baseline_chrony_manage`: whether to manage chrony config/service (default: `true`)
- `baseline_chrony_pools`: list of pool entries for chrony.conf (default: `["pool.ntp.org iburst"]`)
- `baseline_chrony_servers`: list of server entries for chrony.conf (default: `[]`)
- `baseline_chrony_driftfile`: driftfile path (default: `/var/lib/chrony/drift`)
- `baseline_chrony_makestep`: makestep setting (default: `"1.0 3"`)
- `baseline_sysctl`: map of sysctl key/value pairs to enforce (default: `{}`)
