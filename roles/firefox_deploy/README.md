# lit.rhel.firefox_deploy

---
# lit.rhel.firefox_deploy

Install Firefox on RHEL 9 using the shared `lit.rhel.firefox` helper role.

## Requirements

None.

## Variables

See `defaults/main.yml`.

## Dependencies

None.

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: lit.rhel.firefox_deploy
```

## License

MIT

## Author

Lightning IT

## Additional Notes

### Scope

This role:

- validates shared Firefox inputs
- discovers shared Firefox state
- installs the Firefox package
- prepares the system-wide policy directory when enabled

This role does not manage ongoing browser settings, bookmarks, or user profile
preferences. Use `lit.rhel.firefox_config` for that.
