===================================================
Lightning IT Collection Release Notes Release Notes
===================================================

.. contents:: Topics

v1.23.0
=======

Minor Changes
-------------

- Add users_accounts_global as a final user-definition layer whose values take precedence over base and extra definitions for the same account.
- Delegate SELinux, XRDP, and every ``protected-incus`` scenario to the pinned ``modulix-validation`` reusable workflow with an immutable candidate, owner-scoped Incus cleanup, meaningful success markers, and normalized evidence.
- collection_tooling - Synchronize the centrally managed Renovate policy and guarded automation workflows.

v1.22.1
=======

Minor Changes
-------------

- developer_tools - Add configurable Node.js/npm/npx installation and markdownlint-cli2 validation support.
- docs - Apply the shared enterprise README structure.
- docs - Consolidate generated governance metadata and license policy on shared-assets-lit.
- release_model - Add managed compatibility matrix documentation and structured release evidence fields.

Bugfixes
--------

- shared_tooling - Dispatch collection publishing from protected main with the managed release environment and Galaxy credential, make lint compatibility detection rely on the execution environment, and ignore generated local collection-install and Python cache artifacts.

v1.22.0
=======

Minor Changes
-------------

- developer_tools - Add optional actionlint installation from the upstream release archive with checksum verification.

v1.21.0
=======

Bugfixes
--------

- Mark rootless Podman SELinux fcontext add and modify tasks as changed only when their guarded semanage commands run, keeping the role lint-clean while preserving idempotent task gating.

v1.20.0
=======

Minor Changes
-------------

- lit.rhel - Verify automated collection release workflow cycle 2.

v1.19.0
=======

Minor Changes
-------------

- lit.rhel - Verify automated collection release workflow cycle 1.

v1.18.0
=======

Removed Features (previously deprecated)
----------------------------------------

- rhel - Remove stale semantic-release npm configuration from the collection release workflow.
