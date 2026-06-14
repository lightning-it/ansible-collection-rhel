# cloud_image

Build a reusable RHEL qcow2 cloud image artifact on an artifact host or control
node.

This role is intentionally not a VM guest configuration role. It prepares an
image file before the VM exists. Runtime guest configuration remains the scope
of `lit.rhel.virtual_guest`, and Incus import/alias lifecycle should live in an
Incus host role such as `lit.ubuntu.incus_image`.

The role keeps the output image unregistered. It can clean RHSM identity files
from the artifact, but it does not register the image with RHSM or Satellite.
Per-VM registration should happen after boot through `lit.rhel.rhsm`.

## Requirements

The target host that runs this role needs:

- `qemu-img`
- `virt-customize` when `cloud_image_customize_enabled` is `true`
- `tar` when `cloud_image_incus_metadata_enabled` is `true`

On RHEL-like control nodes these tools are commonly provided by packages such
as `qemu-img`, `guestfs-tools`, and `libguestfs`.

## Variables

- `cloud_image_source_path`: existing qcow2 source path. Mutually exclusive
  with `cloud_image_download_url`.
- `cloud_image_download_url`: Red Hat or internal download URL for a qcow2
  source image. Signed URLs are treated as sensitive in task output.
- `cloud_image_checksum`: optional checksum. Supports `sha256:<hex>` or raw
  SHA-256 hex.
- `cloud_image_output_qcow2`: final qcow2 artifact path.
- `cloud_image_resize_enabled`: resize the output image after copy. Default:
  `true`.
- `cloud_image_resize_size`: resize amount or final size accepted by
  `qemu-img resize`. Default: `+1G`.
- `cloud_image_customize_enabled`: run `virt-customize` steps. Default: `true`.
- `cloud_image_customize_ssh_authorized_keys`: optional public keys to inject.
- `cloud_image_customize_run_commands`: optional commands to run inside the
  image.
- `cloud_image_customize_firstboot_commands`: optional first boot commands.
- `cloud_image_incus_vm_cloud_init_enabled`: prepare the image for Incus VM
  cloud-init usage. This enables a datasource list suitable for Incus and wires
  `cloud-init.target` into `multi-user.target`. Default: `false`.
- `cloud_image_incus_vm_cloud_init_datasources`: datasource list written when
  `cloud_image_incus_vm_cloud_init_enabled` is `true`.
- `cloud_image_customize_clean_rhsm`: remove RHSM identity material from the
  image. Default: `true`.
- `cloud_image_incus_metadata_enabled`: create a metadata directory and tarball
  suitable for manual Incus import. Default: `true`.
- `cloud_image_incus_metadata_dir`: metadata directory path.
- `cloud_image_incus_metadata_tarball`: metadata tarball path.

## Example

```yaml
---
- name: Build RHEL 10 cloud image artifact
  hosts: image_builder
  become: true

  roles:
    - role: lit.rhel.cloud_image
      vars:
        cloud_image_source_path: /srv/source/rhel-10.qcow2
        cloud_image_output_qcow2: /srv/incus/images/rhel-10-cloud.qcow2
        cloud_image_owner: rene
        cloud_image_group: incus-admin
```

Manual Incus import can consume the produced artifacts:

```bash
incus image import /srv/rhel-cloud-image/metadata.tar.xz \
  /srv/incus/images/rhel-10-cloud.qcow2 \
  --alias rhel10-ci
```
