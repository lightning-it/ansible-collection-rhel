---
# lit.rhel.firefox_config

Configure Firefox on RHEL 9 using the shared `lit.rhel.firefox` helper role.

## Scope

This role:

- validates shared Firefox inputs
- discovers shared Firefox state
- manages enterprise policies when enabled
- manages optional per-user `user.js` preferences when enabled
- manages proxy, homepage, DNS over HTTPS, telemetry-related settings, bookmarks,
  and download defaults through the cleanest supported mechanism

## Configuration boundaries

- System-wide settings are managed with Firefox enterprise policy
- Optional per-user settings are managed with `user.js`
- Bookmark management is policy-driven; the role does not edit per-user bookmark
  SQLite databases

## Example

```yaml
- hosts: workstations
  roles:
    - role: lit.rhel.firefox_config
```
