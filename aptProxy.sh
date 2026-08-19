#!/usr/bin/env bash
#
# Point the local apt configuration at a running apt-cacher-ng container.
#
# Usage: ./aptProxy.sh [container name]   (default: apt-cacher-ng)

set -Eeuo pipefail

readonly PROGNAME="${0##*/}"
readonly CONF='/etc/apt/apt.conf.d/01proxy'

err() {
  printf '%s: %s\n' "${PROGNAME}" "$*" >&2
}

main() {
  local container="${1:-apt-cacher-ng}"
  local addresses cip proto
  local -a acquire=()

  if (($# > 1)); then
    err "usage: ${PROGNAME} [container name]"
    return 64
  fi

  if [[ ! ${container} =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
    err "invalid container name: ${container}"
    return 64
  fi

  if ! command -v docker > /dev/null 2>&1; then
    err 'docker is required to look up the container address.'
    return 1
  fi

  # Docker 29 removed the flattened NetworkSettings.IPAddress field; the
  # address now only exists per network under NetworkSettings.Networks.
  # Ranging over them works on every version that has Networks and picks the
  # first attached one.
  if ! addresses="$(docker inspect \
    -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' \
    -- "${container}" 2> /dev/null)"; then
    err "cannot inspect a container named ${container}."
    return 1
  fi

  read -r cip _ <<< "${addresses}"

  if [[ -z ${cip} ]]; then
    err "container ${container} has no IP address; is it running?"
    return 1
  fi

  for proto in ftp http https; do
    acquire+=("Acquire::${proto} { Proxy \"http://${cip}:3142\"; }")
  done

  # Rewritten rather than appended: rerunning after the container has been
  # recreated must not leave the previous address behind.
  if [[ -d ${CONF%/*} ]]; then
    printf '%s\n' "${acquire[@]}" | sudo tee "${CONF}" > /dev/null
  else
    printf '%s\n' "${acquire[@]}"
  fi
}

main "$@"
