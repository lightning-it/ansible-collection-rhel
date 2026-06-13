#!/usr/bin/env bash
set -euo pipefail

IMAGE="${WUNDER_DEVTOOLS_IMAGE:-quay.io/l-it/ee-wunder-devtools-ubi9:v1.8.3}"
WUNDER_DEVTOOLS_LOCAL_CONTEXT="${WUNDER_DEVTOOLS_LOCAL_CONTEXT:-}"
WUNDER_DEVTOOLS_LOCAL_IMAGE="${WUNDER_DEVTOOLS_LOCAL_IMAGE:-local/ee-wunder-devtools-ubi9:dev}"
CONTAINER_HOME="${CONTAINER_HOME:-/tmp/wunder}"
HOST_HOME_CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/wunder-devtools-ee/v2/home"
HOST_HOME_CACHE_SCOPE="host-uid-$(id -u)"
if [ "${WUNDER_DEVTOOLS_RUN_AS_HOST_UID:-0}" != "1" ]; then
  HOST_HOME_CACHE_SCOPE="container-root"
fi
HOST_HOME_CACHE="${HOST_HOME_CACHE:-${HOST_HOME_CACHE_ROOT}/${HOST_HOME_CACHE_SCOPE}}"

mkdir -p "$HOST_HOME_CACHE"
chmod 700 "$HOST_HOME_CACHE" 2>/dev/null || true

WORKSPACE_MOUNT="${PWD}:/workspace"
HOME_CACHE_MOUNT="${HOST_HOME_CACHE}:${CONTAINER_HOME}"
DOCKER_ARGS=(
  -w /workspace
  -e HOME="${CONTAINER_HOME}"
)

fail_or_skip() {
  local msg="$1"
  if [ "${CI:-}" = "true" ] || [ "${WUNDER_DEVTOOLS_STRICT:-0}" = "1" ]; then
    echo "Error: ${msg}" >&2
    exit 1
  fi
  echo "WARN: ${msg} (skipping local hook; set WUNDER_DEVTOOLS_STRICT=1 to enforce)." >&2
  exit 0
}

sanitize_docker_host_env() {
  if [[ "${DOCKER_HOST:-}" == unix://* ]]; then
    host_sock="${DOCKER_HOST#unix://}"
    if [ ! -S "$host_sock" ]; then
      unset DOCKER_HOST
    fi
  fi
}

docker_usable() {
  command -v docker >/dev/null 2>&1 || return 1
  sanitize_docker_host_env
  docker info >/dev/null 2>&1
}

podman_usable() {
  command -v podman >/dev/null 2>&1 || return 1
  podman info >/dev/null 2>&1
}

image_exists() {
  "$CONTAINER_BIN" image inspect "$1" >/dev/null 2>&1
}

build_local_image() {
  local context="$1"
  local dockerfile="${context}/Dockerfile"

  if [ ! -f "$dockerfile" ]; then
    fail_or_skip "WUNDER_DEVTOOLS_LOCAL_CONTEXT does not contain a Dockerfile: ${context}"
  fi

  "$CONTAINER_BIN" build \
    -t "$WUNDER_DEVTOOLS_LOCAL_IMAGE" \
    -f "$dockerfile" \
    "$context"
}

realpath_portable() {
  local path="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import os
print(os.path.realpath("${path}"))
PY
    return
  fi
  printf '%s\n' "$path"
}

CONTAINER_BIN="${WUNDER_CONTAINER_ENGINE:-}"
if [ -z "$CONTAINER_BIN" ]; then
  if docker_usable; then
    CONTAINER_BIN="docker"
  elif podman_usable; then
    CONTAINER_BIN="podman"
  else
    fail_or_skip "no usable container engine found (docker/podman not running or unreachable)"
  fi
fi

case "$CONTAINER_BIN" in
  podman|docker) ;;
  *)
    fail_or_skip "unsupported engine '$CONTAINER_BIN' (use podman|docker)"
    ;;
esac

if [ -n "$WUNDER_DEVTOOLS_LOCAL_CONTEXT" ]; then
  IMAGE="$WUNDER_DEVTOOLS_LOCAL_IMAGE"
  if [ "${WUNDER_DEVTOOLS_LOCAL_BUILD:-auto}" = "1" ] || ! image_exists "$IMAGE"; then
    build_local_image "$WUNDER_DEVTOOLS_LOCAL_CONTEXT"
  fi
fi

if [ "$CONTAINER_BIN" = "podman" ] && [ "$(uname -s)" = "Linux" ]; then
  WORKSPACE_MOUNT="${WORKSPACE_MOUNT}:Z"
  HOME_CACHE_MOUNT="${HOME_CACHE_MOUNT}:Z"
fi

DOCKER_ARGS+=(-v "$WORKSPACE_MOUNT")
DOCKER_ARGS+=(-v "$HOME_CACHE_MOUNT")

PODMAN_ROOTLESS=0
if [ "$CONTAINER_BIN" = "podman" ]; then
  podman_rootless="$(podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null || true)"
  if [ "${podman_rootless}" = "true" ]; then
    PODMAN_ROOTLESS=1
  fi
fi

DOCKER_SOCKET=""
if [[ "${DOCKER_HOST:-}" == unix://* ]]; then
  host_sock="${DOCKER_HOST#unix://}"
  if [ -S "$host_sock" ]; then
    DOCKER_SOCKET="$host_sock"
  fi
elif [ -S "/run/user/$(id -u)/podman/podman.sock" ]; then
  DOCKER_SOCKET="/run/user/$(id -u)/podman/podman.sock"
elif [ -S "$HOME/.docker/run/docker.sock" ]; then
  DOCKER_SOCKET="$HOME/.docker/run/docker.sock"
elif [ -S /var/run/docker.sock ]; then
  DOCKER_SOCKET="/var/run/docker.sock"
fi

if [ -n "$DOCKER_SOCKET" ]; then
  DOCKER_SOCKET_REAL="$(realpath_portable "$DOCKER_SOCKET")"

  DOCKER_ARGS+=(-v "$DOCKER_SOCKET_REAL":/var/run/docker.sock)
  DOCKER_ARGS+=(-e DOCKER_HOST=unix:///var/run/docker.sock)

  DOCKER_ARGS+=(
    -e HTTP_PROXY=
    -e HTTPS_PROXY=
    -e NO_PROXY=
    -e http_proxy=
    -e https_proxy=
    -e no_proxy=
  )

  if [ "${WUNDER_DEVTOOLS_RUN_AS_HOST_UID:-0}" = "1" ]; then
    DOCKER_ARGS+=(--user "$(id -u):$(id -g)")
    DOCKER_ARGS+=(--group-add 0)

    socket_gid="$(
      stat -c %g "$DOCKER_SOCKET_REAL" 2>/dev/null \
      || stat -f %g "$DOCKER_SOCKET_REAL" 2>/dev/null \
      || true
    )"
    if [ -n "${socket_gid:-}" ]; then
      DOCKER_ARGS+=(--group-add "$socket_gid")
    fi
  else
    DOCKER_ARGS+=(--user 0:0)
    DOCKER_ARGS+=(--group-add 0)
  fi
elif [ "${PODMAN_ROOTLESS}" = "1" ]; then
  DOCKER_ARGS+=(--user 0:0)
fi

INCUS_CONFIG_DIR="${INCUS_CONFIG_DIR:-$HOME/.config/incus}"
if [ -d "$INCUS_CONFIG_DIR" ]; then
  DOCKER_ARGS+=(-v "${INCUS_CONFIG_DIR}:${CONTAINER_HOME}/.config/incus:ro")
fi

INCUS_SOCKET_HOST="${INCUS_SOCKET:-}"
if [[ "$INCUS_SOCKET_HOST" == unix://* ]]; then
  INCUS_SOCKET_HOST="${INCUS_SOCKET_HOST#unix://}"
fi
if [ -z "$INCUS_SOCKET_HOST" ]; then
  if [ -S /run/incus/unix.socket ]; then
    INCUS_SOCKET_HOST="/run/incus/unix.socket"
  elif [ -S /var/lib/incus/unix.socket ]; then
    INCUS_SOCKET_HOST="/var/lib/incus/unix.socket"
  elif [ -S "$HOME/.config/incus/unix.socket" ]; then
    INCUS_SOCKET_HOST="$HOME/.config/incus/unix.socket"
  fi
fi
if [ -n "$INCUS_SOCKET_HOST" ] && [ -S "$INCUS_SOCKET_HOST" ]; then
  INCUS_SOCKET_REAL="$(realpath_portable "$INCUS_SOCKET_HOST")"
  DOCKER_ARGS+=(-v "$INCUS_SOCKET_REAL":/var/lib/incus/unix.socket)
  DOCKER_ARGS+=(-e INCUS_SOCKET=/var/lib/incus/unix.socket)
fi

if [ "$(uname -s)" = "Linux" ]; then
  DOCKER_ARGS+=(--add-host=host.docker.internal:host-gateway)
fi

if [ "$CONTAINER_BIN" = "docker" ]; then
  if [ -n "$DOCKER_SOCKET" ]; then
    export DOCKER_HOST="unix://${DOCKER_SOCKET_REAL}"
  else
    sanitize_docker_host_env
    if [ -z "${DOCKER_HOST:-}" ] && [ -S "/run/user/$(id -u)/podman/podman.sock" ]; then
      podman_socket="/run/user/$(id -u)/podman/podman.sock"
      export DOCKER_HOST="unix://${podman_socket}"
    fi
  fi
fi

"$CONTAINER_BIN" run --rm \
  --entrypoint "" \
  "${DOCKER_ARGS[@]}" \
  ${ANSIBLE_COLLECTIONS_PATH:+-e ANSIBLE_COLLECTIONS_PATH} \
  ${ANSIBLE_ROLES_PATH:+-e ANSIBLE_ROLES_PATH} \
  ${ANSIBLE_CORE_VERSION:+-e ANSIBLE_CORE_VERSION} \
  ${ANSIBLE_LINT_VERSION:+-e ANSIBLE_LINT_VERSION} \
  ${ANSIBLE_LINT_SKIP_META_RUNTIME:+-e ANSIBLE_LINT_SKIP_META_RUNTIME} \
  ${COLLECTION_NAMESPACE:+-e COLLECTION_NAMESPACE} \
  ${COLLECTION_NAME:+-e COLLECTION_NAME} \
  ${EXAMPLE_PLAYBOOK:+-e EXAMPLE_PLAYBOOK} \
  ${MOLECULE_NO_LOG:+-e MOLECULE_NO_LOG} \
  ${INCUS_DIR:+-e INCUS_DIR} \
  ${INCUS_MODE:+-e INCUS_MODE} \
  ${INCUS_REMOTE:+-e INCUS_REMOTE} \
  ${INCUS_RHEL_MAJOR_VERSION:+-e INCUS_RHEL_MAJOR_VERSION} \
  ${INCUS_RHEL9_IMAGE:+-e INCUS_RHEL9_IMAGE} \
  ${INCUS_RHEL10_IMAGE:+-e INCUS_RHEL10_IMAGE} \
  ${INCUS_INSTANCE_NAME:+-e INCUS_INSTANCE_NAME} \
  ${INCUS_SSH_PRIVATE_KEY:+-e INCUS_SSH_PRIVATE_KEY} \
  ${INCUS_SSH_PUBLIC_KEY:+-e INCUS_SSH_PUBLIC_KEY} \
  ${INCUS_SSH_PUBLIC_KEY_FILE:+-e INCUS_SSH_PUBLIC_KEY_FILE} \
  ${VAGRANT_SSH_HOST:+-e VAGRANT_SSH_HOST} \
  ${VAGRANT_SSH_PORT:+-e VAGRANT_SSH_PORT} \
  ${VAGRANT_SSH_USER:+-e VAGRANT_SSH_USER} \
  ${VAGRANT_SSH_KEY:+-e VAGRANT_SSH_KEY} \
  "$IMAGE" "$@"
