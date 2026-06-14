# virtual_guest

Configure reusable RHEL virtual machine guest baseline packages and services.

This role is intentionally narrow. It does not register RHEL systems, enable
repositories, install application packages, or prepare hosts for a specific
service. Use it after `lit.rhel.rhsm` and `lit.rhel.repos` when those are
required.

## Scope

- Install VM guest baseline packages.
- Enable and start the matching guest agent for the detected virtualization type.
- Keep guest behavior reusable across future VM workloads.

## Variables

- `virtual_guest_enabled`: enable or skip the role. Default: `true`.
- `virtual_guest_packages`: packages to install. Defaults are OS-specific.
- `virtual_guest_manage_packages`: install `virtual_guest_packages`. Default: `true`.
- `virtual_guest_manage_qemu_guest_agent`: install and enable/start QEMU guest agent on QEMU/KVM guests. Default: `true`.
- `virtual_guest_qemu_guest_agent_packages`: QEMU guest agent packages.
- `virtual_guest_qemu_guest_agent_service`: QEMU guest agent service name.
- `virtual_guest_qemu_guest_agent_virtualization_types`: virtualization types treated as QEMU/KVM guests.
- `virtual_guest_manage_vmware_guest_agent`: install and enable/start VMware guest agent on VMware guests. Default: `true`.
- `virtual_guest_vmware_guest_agent_packages`: VMware guest agent packages.
- `virtual_guest_vmware_guest_agent_service`: VMware guest agent service name.
- `virtual_guest_vmware_guest_agent_virtualization_types`: virtualization types treated as VMware guests.

## Example

```yaml
- hosts: rhel_vms
  become: true
  roles:
    - role: lit.rhel.rhsm
      vars:
        rhsm_method: rhsm
        rhsm_org: "{{ lookup('ansible.builtin.env', 'RHSM_ORG_ID') }}"
        rhsm_activation_key: "{{ lookup('ansible.builtin.env', 'RHSM_ACTIVATION_KEY') }}"
    - role: lit.rhel.repos
      vars:
        repos_rhsm_repositories:
          - rhel-10-for-x86_64-baseos-rpms
          - rhel-10-for-x86_64-appstream-rpms
    - role: lit.rhel.virtual_guest
```
