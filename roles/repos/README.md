# Repos Role

Manage RHEL repositories by enabling/disabling IDs via subscription-manager and creating custom yum repo definitions.

## Variables

- `repos_enabled`: list of repo IDs to enable (default: `[]`).
- `repos_disabled`: list of repo IDs to disable (default: `[]`).
- `repos_custom`: list of custom repositories managed via `yum_repository`. Example:

  ```yaml
  repos_custom:
    - id: custom-appstream
      name: Custom AppStream
      baseurl: http://repo.example.com/appstream
      enabled: true
      gpgcheck: false
  ```

## Example

```yaml
- hosts: all
  become: true

  roles:
    - role: lit.rhel.repos
      vars:
        repos_enabled:
          - rhel-9-baseos-rpms
          - rhel-9-appstream-rpms
        repos_disabled:
          - codeready-builder-for-rhel-9-x86_64-rpms
        repos_custom:
          - id: internal-tools
            name: Internal Tools
            baseurl: http://repo.example.com/tools
            enabled: true
            gpgcheck: false
```
