---
# lit.rhel.developer_tools

Install developer-oriented packages, Python packages, and optional CLI binaries on RHEL.

## Requirements

- RHEL / EL 9 host
- `become: true` for package and repository management
- Run `gh auth login --git-protocol ssh` manually after provisioning if GitHub access is needed

## Variables

See `defaults/main.yml` for the full interface. Key inputs:

```yaml
developer_tools_enabled: true
developer_tools_packages_present: []
developer_tools_pip_executable: pip3
developer_tools_pip_packages_present: []

developer_tools_github_cli_enabled: false
developer_tools_github_cli_package_name: gh
developer_tools_github_cli_repo_name: gh-cli
developer_tools_github_cli_repo_description: packages for the GitHub CLI
developer_tools_github_cli_repo_baseurl: https://cli.github.com/packages/rpm
developer_tools_github_cli_repo_gpgcheck: true
developer_tools_github_cli_repo_gpgkey: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x23F3D4EA75716059

developer_tools_argocd_cli_enabled: false
developer_tools_argocd_cli_version: v3.3.3
developer_tools_argocd_cli_url: "https://github.com/argoproj/argo-cd/releases/download/{{ developer_tools_argocd_cli_version }}/argocd-linux-amd64"
developer_tools_argocd_cli_dest: /usr/local/bin/argocd

developer_tools_oc_cli_enabled: false
developer_tools_oc_cli_version: 4.18.24
developer_tools_oc_cli_archive_url: "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/{{ developer_tools_oc_cli_version }}/openshift-client-linux-amd64-rhel9-{{ developer_tools_oc_cli_version }}.tar.gz"
developer_tools_oc_cli_archive_path: "/var/tmp/openshift-client-linux-amd64-rhel9-{{ developer_tools_oc_cli_version }}.tar.gz"
developer_tools_oc_cli_extract_dir: "/var/tmp/openshift-client-{{ developer_tools_oc_cli_version }}"
developer_tools_oc_cli_dest: /usr/local/bin/oc

developer_tools_kubectl_cli_enabled: false
developer_tools_kubectl_cli_dest: /usr/local/bin/kubectl
```

- When `developer_tools_github_cli_enabled` is true, the role configures the official GitHub CLI RPM repository and installs `gh`.

## Dependencies

None.

## Example Playbook

```yaml
- hosts: workbenches
  become: true
  roles:
    - role: lit.rhel.developer_tools
      vars:
        developer_tools_packages_present:
          - git
          - podman
```

## License

MIT

## Author

Lightning IT
