#!/usr/bin/env bash
set -euo pipefail

IMAGE="${WUNDER_DEVTOOLS_EE_IMAGE:-ghcr.io/lightning-it/wunder-devtools-ee:v1.1.2}"
CONTAINER_HOME="${CONTAINER_HOME:-/tmp/wunder}"
HOST_HOME_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wunder-devtools-ee/home"

mkdir -p "$HOST_HOME_CACHE"

DOCKER_ARGS=(
  -v "$PWD":/workspace
  -w /workspace
  -e HOME="${CONTAINER_HOME}"
  -v "$HOST_HOME_CACHE":"${CONTAINER_HOME}"
)

# Mount Docker socket (supports Docker Desktop/Colima path on macOS too)
DOCKER_SOCKET=""
if [ -S /var/run/docker.sock ]; then
  DOCKER_SOCKET="/var/run/docker.sock"
elif [ -S "$HOME/.docker/run/docker.sock" ]; then
  DOCKER_SOCKET="$HOME/.docker/run/docker.sock"
fi

if [ -n "$DOCKER_SOCKET" ]; then
  DOCKER_ARGS+=(-v "$DOCKER_SOCKET":/var/run/docker.sock)
  DOCKER_ARGS+=(-e DOCKER_HOST=unix:///var/run/docker.sock)

  # By default, run as host UID to avoid permission issues with bind mounts.
  # For SSH-heavy workflows (e.g. Vagrant + Molecule), this can be disabled by
  # setting WUNDER_DEVTOOLS_RUN_AS_HOST_UID=0 so that the container user (e.g. "wunder")
  # is used instead (and has a valid /etc/passwd entry).
  if [ "${WUNDER_DEVTOOLS_RUN_AS_HOST_UID:-1}" = "1" ]; then
    DOCKER_ARGS+=(--user "$(id -u):$(id -g)")
    DOCKER_ARGS+=(--group-add 0)

    socket_gid="$(
      stat -c %g /var/run/docker.sock 2>/dev/null \
      || stat -f %g /var/run/docker.sock 2>/dev/null \
      || true
    )"
    if [ -n "${socket_gid:-}" ]; then
      DOCKER_ARGS+=(--group-add "$socket_gid")
    fi
  fi
fi

# On Linux runners, provide host.docker.internal → host-gateway
if [ "$(uname -s)" = "Linux" ]; then
  DOCKER_ARGS+=(--add-host=host.docker.internal:host-gateway)
fi

docker run --rm \
  --entrypoint "" \
  "${DOCKER_ARGS[@]}" \
  ${ANSIBLE_COLLECTIONS_PATHS:+-e ANSIBLE_COLLECTIONS_PATHS} \
  ${ANSIBLE_ROLES_PATH:+-e ANSIBLE_ROLES_PATH} \
  ${ANSIBLE_CORE_VERSION:+-e ANSIBLE_CORE_VERSION} \
  ${ANSIBLE_LINT_VERSION:+-e ANSIBLE_LINT_VERSION} \
  ${COLLECTION_NAMESPACE:+-e COLLECTION_NAMESPACE} \
  ${COLLECTION_NAME:+-e COLLECTION_NAME} \
  ${EXAMPLE_PLAYBOOK:+-e EXAMPLE_PLAYBOOK} \
  ${MOLECULE_NO_LOG:+-e MOLECULE_NO_LOG} \
  ${VAGRANT_SSH_HOST:+-e VAGRANT_SSH_HOST} \
  ${VAGRANT_SSH_PORT:+-e VAGRANT_SSH_PORT} \
  ${VAGRANT_SSH_USER:+-e VAGRANT_SSH_USER} \
  ${VAGRANT_SSH_KEY:+-e VAGRANT_SSH_KEY} \
  "$IMAGE" "$@"
