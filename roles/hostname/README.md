# lit.rhel.hostname

Set the system hostname and optionally manage a matching `/etc/hosts` entry.
The short hostname is derived from the first label of the FQDN.

## Variables

- `hostname_fqdn` (string, default: `{{ inventory_hostname }}`): Desired FQDN.
  If empty or undefined, `inventory_hostname` is used.
- `hostname_manage_etc_hosts` (bool, default: `true`): Manage `/etc/hosts` entry.
- `hostname_etc_hosts_ip` (string, default: `"127.0.1.1"`): IP address to map to the hostname.
- `hostname_add_shortname` (bool, default: `true`): Add short hostname alias
  when it differs from the FQDN.

## Example

```yaml
- name: Configure hostname on RHEL hosts
  hosts: rhel
  become: true

  roles:
    - role: lit.rhel.hostname
      vars:
        hostname_fqdn: "app01.prod.example.com"
```

To skip `/etc/hosts` management:

```yaml
    - role: lit.rhel.hostname
      vars:
        hostname_manage_etc_hosts: false
```
