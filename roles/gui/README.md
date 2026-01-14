# lit.rhel.gui

Install a GUI stack on RHEL 9. Supports **GNOME** and **XFCE** (best-effort).

## Usage
```yaml
- hosts: rhel_hosts
  become: true
  roles:
    - role: lit.rhel.gui
      vars:
        gui_variant: gnome   # or xfce
```

## Notes
- GNOME uses the RHEL group **"Server with GUI"**.
- XFCE is best-effort and may require additional repositories depending on your environment.
- For GNOME, this role can enable/start `gdm` when `gui_enable_display_manager: true`.
- For XFCE, no display manager is enforced by default (XRDP doesn't require it).

## Variables
- `gui_variant`: `gnome` or `xfce`
- `gui_set_graphical_target`: set default boot target to `graphical.target` (default true)
- `gui_enable_display_manager`: enable/start `gdm` for GNOME (default true)
