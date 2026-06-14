# RHSM Role

Register or unregister RHEL systems with Red Hat Subscription Management (RHSM)
or Satellite using activation keys or user credentials.

## Variables

- `rhsm_state`: desired state (`present` | `absent`). Default: `present`.
- `rhsm_method`: registration method (`none` | `rhsm` | `satellite`). Default: `none`.
- `rhsm_org`: RHSM organization ID (required for activation key registration).
- `rhsm_activation_key`: activation key to register with RHSM/Satellite.
- `rhsm_username` / `rhsm_password`: credentials for RHSM registration (use activation keys whenever possible).
- `rhsm_auto_attach`: whether to auto-attach subscriptions (default: `true`).
- `rhsm_force_register`: unregister and register again even if already registered.
- `rhsm_clean_on_absent`: run `subscription-manager clean` when state is absent.
- `rhsm_server`: Satellite hostname when using Satellite (optional).
- `rhsm_baseurl`: Base URL for content (Satellite) (optional).

## Example (Activation Key)

```yaml
- hosts: all
  become: true

  roles:
    - role: lit.rhel.rhsm
      vars:
        rhsm_method: rhsm
        rhsm_org: MYORG
        rhsm_activation_key: RHEL9-ACTIVATION
```

## Example (Unregister)

```yaml
- hosts: all
  become: true

  roles:
    - role: lit.rhel.rhsm
      vars:
        rhsm_method: rhsm
        rhsm_state: absent
```

## Example (Satellite)

```yaml
- hosts: all
  become: true

  roles:
    - role: lit.rhel.rhsm
      vars:
        rhsm_method: satellite
        rhsm_org: MYORG
        rhsm_activation_key: RHEL9-SAT
        rhsm_server: satellite.example.com
        rhsm_baseurl: https://satellite.example.com/pulp/content
```
