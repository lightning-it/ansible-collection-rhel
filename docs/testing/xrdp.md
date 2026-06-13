# XRDP Incus VM Testing

The `lit.rhel.xrdp` role supports RedHat-family RHEL major versions `9` and
`10`. Generic defaults are in `roles/xrdp/defaults/main.yml`; package names,
service names, desktop package groups, and SELinux defaults are loaded from:

- `roles/xrdp/vars/RedHat-9.yml`
- `roles/xrdp/vars/RedHat-10.yml`

## Scenarios

The Incus VM scenarios are:

- `xrdp-rhel9`
- `xrdp-rhel10`

They use Molecule create/destroy playbooks with externally managed Incus VMs and
the existing Incus wrapper scripts:

```bash
deploy/incus/scripts/create.sh --version 9 --mode vm --name <instance>
deploy/incus/scripts/create.sh --version 10 --mode vm --name <instance>
deploy/incus/scripts/destroy.sh --name <instance>
```

The scenarios create unique instance names by default and write Molecule
instance config into the scenario ephemeral directory so cleanup can destroy the
VM after failures.

## Run RHEL 9

```bash
INCUS_RHEL9_IMAGE=local:rhel9-ci molecule test -s xrdp-rhel9
```

## Run RHEL 10

```bash
INCUS_RHEL10_IMAGE=local:rhel10-ci molecule test -s xrdp-rhel10
```

## Iterative RHEL 10 Development

```bash
INCUS_RHEL10_IMAGE=local:rhel10-ci molecule converge -s xrdp-rhel10
INCUS_RHEL10_IMAGE=local:rhel10-ci molecule verify -s xrdp-rhel10
```

When running through the local devtools container:

```bash
WUNDER_DEVTOOLS_LOCAL_CONTEXT=/Users/rene/sources/lit/NEW/container-wunder-devtools-ee \
WUNDER_DEVTOOLS_LOCAL_IMAGE=local/ee-wunder-devtools-ubi9:incus \
WUNDER_DEVTOOLS_LOCAL_BUILD=0 \
INCUS_RHEL10_IMAGE=local:rhel10-ci \
bash scripts/devtools-molecule.sh xrdp-rhel10
```

## Functional RDP Check

The verify playbook does more than check `systemctl`:

- Confirms `xrdp` is enabled.
- Confirms `xrdp` is active.
- Confirms TCP/3389 is listening.
- Confirms firewalld has `3389/tcp` in the public zone.
- Uses FreeRDP from the controller to authenticate to the VM.

The FreeRDP command uses `/cert:ignore` only for automated testing against the
test VM certificate. If the installed FreeRDP supports `/auth-only`, the
scenario uses it. Otherwise it runs a bounded `timeout` session and fails on
authentication, TLS, certificate, or connection errors.

The scenario creates a dedicated non-root user named `xrdptest` inside the
disposable VM. The generated password is stored only under Molecule's ephemeral
directory and is not printed in logs.

## Protected CI

Real-RHEL Incus VM testing should run only on trusted self-hosted runners with
Incus installed and private images preloaded as `local:rhel9-ci` and
`local:rhel10-ci`, or equivalent aliases passed through `INCUS_RHEL9_IMAGE` and
`INCUS_RHEL10_IMAGE`.

Public pull-request CI must not require private RHEL images, Red Hat credentials,
subscription-manager credentials, or GitHub secrets.

## Troubleshooting

- Service: run `systemctl status xrdp xrdp-sesman`.
- Listener: run `ss -ltnp | grep ':3389'`.
- Firewall: run `firewall-cmd --zone=public --list-ports`.
- SELinux: run `semanage port -l | grep 3389` and check audit logs.
- PAM/authentication: check `/var/log/secure` and `/var/log/xrdp-sesman.log`.
- XRDP protocol/TLS: check `/var/log/xrdp.log`.
- Desktop startup: check `/etc/xrdp/startwm.sh`, installed session packages,
  and `/var/log/xrdp-sesman.log`.
- FreeRDP controller: run `xfreerdp /help` and confirm `/auth-only` support.
