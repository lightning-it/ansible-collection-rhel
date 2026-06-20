# Incus Local Deployment

This workflow provides the local deployment path for Incus-backed RHEL-family
testing.

Defaults:

- RHEL major version: `10`
- Incus mode: `vm`
- RHEL 10 public/local image: `images:rockylinux/10/cloud`
- RHEL 9 public/local image: `images:rockylinux/9/cloud`

The public defaults use RHEL-compatible community images and do not require Red
Hat credentials. Testing actual RHEL 9 or RHEL 10 should use a private Incus
image already loaded on a trusted runner or workstation, for example
`local:rhel9-ci` or `local:rhel10-ci`.

Do not publish private RHEL images as workflow artifacts or public caches.

## Create RHEL 10 VM

```bash
deploy/incus/scripts/create.sh
```

Equivalent explicit form:

```bash
deploy/incus/scripts/create.sh --version 10 --mode vm --name lit-rhel10-vm
```

## Create RHEL 9 VM

```bash
deploy/incus/scripts/create.sh --version 9 --mode vm --name lit-rhel9-vm
```

## Create A Container

```bash
deploy/incus/scripts/create.sh --version 10 --mode container --name lit-rhel10-container
```

## Use Private RHEL Images

Use environment variables to select private local aliases without changing repo
files:

```bash
INCUS_RHEL10_IMAGE=local:rhel10-ci deploy/incus/scripts/create.sh --version 10
INCUS_RHEL9_IMAGE=local:rhel9-ci deploy/incus/scripts/create.sh --version 9
```

The protected CI workflow uses the same variables and defaults to those local
aliases on the self-hosted runner.

## SSH Keys

By default the create script injects the first existing local public key from:

- `~/.ssh/id_ed25519.pub`
- `~/.ssh/id_rsa.pub`

Override this with:

```bash
deploy/incus/scripts/create.sh --public-key-file ~/.ssh/work.pub
deploy/incus/scripts/create.sh --public-key "ssh-ed25519 AAAA..."
```

When `--public-key` is used, set `INCUS_SSH_PRIVATE_KEY` if the generated
inventory should point to a matching private key.

## Run Ansible

The create script writes an inventory file under `deploy/incus/generated/`.

```bash
ansible-playbook -i deploy/incus/generated/lit-rhel10-vm.ini playbooks/selinux.yml
```

You can also regenerate inventory for an existing instance:

```bash
deploy/incus/scripts/inventory.sh --name lit-rhel10-vm > deploy/incus/generated/lit-rhel10-vm.ini
```

## Destroy

```bash
deploy/incus/scripts/destroy.sh --name lit-rhel10-vm
```

## Molecule Heavy Tests

Heavy Molecule scenarios use Incus targets only. Run the SELinux heavy scenario
through the helper script:

```bash
scripts/devtools-incus-selinux-heavy.sh
```

The helper defaults to `INCUS_MODE=vm`. Use `INCUS_MODE=container` only for
roles that support containerized system testing.
