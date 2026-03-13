---
# lit.rhel.firefox_destroy

Remove managed Firefox state on RHEL 9 using the shared `lit.rhel.firefox`
helper role.

## Scope

This role can:

- remove managed enterprise policies
- remove managed bookmarks from the enterprise policy file
- remove managed per-user `user.js`
- remove the Firefox package when requested

Teardown is controlled by shared variables:

```yaml
firefox_remove_package: false
firefox_remove_config: false
firefox_remove_policies: false
firefox_remove_bookmarks: false
```

## Example

```yaml
- hosts: workstations
  roles:
    - role: lit.rhel.firefox_destroy
```
