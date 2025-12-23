# Firewalld Role

Installs and manages `firewalld`, optionally enabling selected services or ports.

## Usage

```yaml
- hosts: all
  roles:
    - role: lit.rhel.firewalld
      vars:
        firewalld_manage_service: true
        firewalld_services:
          - ssh
        firewalld_ports:
          - 8080/tcp
```

## Variables

- `firewalld_manage_service`: toggles whether the role starts/enables firewalld (default: `true`)
- `firewalld_services`: list of service names to allow via `ansible.posix.firewalld` (default: `["ssh"]`)
- `firewalld_ports`: list of `<port>/<proto>` entries to open (default: `[]`)
