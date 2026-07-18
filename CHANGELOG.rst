===================================================
Lightning IT Collection Release Notes Release Notes
===================================================

.. contents:: Topics

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
