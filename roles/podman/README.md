# Podman Role

Installs Podman tooling, prepares the container configuration directory, and can
configure rootless Podman storage for a dedicated runtime user.

## Requirements

- RHEL-compatible host with package repositories available.
- `community.general` when SELinux fcontext management is enabled.

## Variables

See `defaults/main.yml`.

Important inputs:

- `podman_package_manage`: install Podman packages with the system package
  manager (default: `true`). Set this to `false` for prepared or disconnected
  hosts where Podman is already installed and repositories are intentionally
  unavailable.
- `podman_packages`: package list installed via `ansible.builtin.package`
  (default: `["podman", "buildah", "fuse-overlayfs", "slirp4netns", "shadow-utils"]`)
- `podman_registries_conf_dir`: directory ensured present for registry
  configuration files (default: `/etc/containers`)
- `podman_rootless_storage_manage`: enable rootless storage configuration.
- `podman_rootless_storage_user`: runtime user, for example `aap`.
- `podman_rootless_storage_base_path`: base path, for example `/appl/podman`.
- `podman_rootless_storage_path`: graphroot path, for example `/appl/podman/storage`.
- `podman_rootless_storage_validate`: validate the effective graphroot with
  `podman info`.

When rootless storage management is enabled, the role also prepares
`/run/user/<uid>` for the configured runtime user. This supports service-style
Ansible executions where no interactive login created the runtime directory yet.

## Dependencies

- `community.general` for SELinux fcontext management.

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: lit.rhel.podman
      vars:
        podman_rootless_storage_manage: true
        podman_rootless_storage_user: aap
        podman_rootless_storage_base_path: /appl/podman
        podman_rootless_storage_path: /appl/podman/storage
```

## License

MIT

## Author

Lightning IT
