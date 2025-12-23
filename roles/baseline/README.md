# Baseline Role

Installs a minimal set of operational packages and configures timezone, locale, and optional sysctl defaults.

## Usage

```yaml
- hosts: all
  roles:
    - role: lit.rhel.baseline
      vars:
        baseline_packages_present:
          - vim
        baseline_timezone: Europe/Berlin
        baseline_locale: en_US.UTF-8
        baseline_sysctl:
          net.ipv4.ip_forward: 0
```

## Variables

- `baseline_packages_present`: list of packages to ensure are installed (default: `["vim", "jq", "tar", "bash-completion"]`)
- `baseline_timezone`: IANA timezone string configured via `community.general.timezone` (default: `Etc/UTC`, set empty to skip)
- `baseline_locale`: locale string written to `/etc/locale.conf` (default: `en_US.UTF-8`, set empty to skip)
- `baseline_sysctl`: map of sysctl key/value pairs to enforce (default: `{}`)
