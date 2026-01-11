# lit.rhel.automatic_updates

Configure weekly automatic OS updates on RHEL systems via a cron job. By default
it runs `dnf -y update` every Sunday at 06:00 and writes output to
`/var/log/dnf-auto-weekly.log`. This role does **not** use the
`dnf-automatic`/systemd timers; it is purely cron-based for simplicity.

## Variables

- `automatic_updates_enabled` (bool, default: `true`): Enable/disable the cron job.
- `automatic_updates_minute` (string, default: `"0"`): Cron minute field.
- `automatic_updates_hour` (string, default: `"6"`): Cron hour field.
- `automatic_updates_weekday` (string, default: `"0"`): Cron weekday field (`0`/`7` = Sunday).
- `automatic_updates_user` (string, default: `"root"`): User owning the cron entry.
- `automatic_updates_log_file` (string, default: `"/var/log/dnf-auto-weekly.log"`): Log destination for stdout/stderr.
- `automatic_updates_command` (string, default: `"dnf -y update"`): Command to run (switch to `yum` if preferred).
- `automatic_updates_cron_name` (string, default: `"Weekly automatic updates"`): Cron entry name.

## Example

```yaml
- name: Enable weekly updates on RHEL hosts
  hosts: rhel
  become: true

  roles:
    - role: lit.rhel.automatic_updates
      vars:
        automatic_updates_minute: "15"
        automatic_updates_hour: "4"
        automatic_updates_weekday: "1"  # Mondays 04:15
```

To disable:

```yaml
    - role: lit.rhel.automatic_updates
      vars:
        automatic_updates_enabled: false
```

Logs are written to `automatic_updates_log_file`. Adjust the command/log
path or schedule as needed.
