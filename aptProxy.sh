#!/bin/bash
# Point the local apt configuration at a running apt-cacher-ng container.
#
# Usage: ./aptProxy.sh [container name]   (default: apt-cacher-ng)

set -euo pipefail

container="${1:-apt-cacher-ng}"
conf='/etc/apt/apt.conf.d/01proxy'

if ! command -v docker > /dev/null 2>&1; then
  echo "docker is required to look up the container address." >&2
  exit 1
fi

# Docker 29 removed the flattened NetworkSettings.IPAddress field; the address
# now only exists per network under NetworkSettings.Networks. Ranging over them
# works on every version that has Networks and picks the first attached one.
if ! addresses="$(docker inspect \
  -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' \
  "${container}" 2> /dev/null)"; then
  echo "No container named ${container}." >&2
  exit 1
fi

cip=''
for addr in ${addresses}; do
  if [[ -n "${addr}" ]]; then
    cip="${addr}"
    break
  fi
done

if [[ -z "${cip}" ]]; then
  echo "Container ${container} has no IP address; is it running?" >&2
  exit 1
fi

for proto in ftp http https; do
  acquire="Acquire::${proto} { Proxy \"http://${cip}:3142\"; }"
  if [[ -d "$(dirname "${conf}")" ]]; then
    printf '%s\n' "${acquire}" | sudo tee --append "${conf}" > /dev/null
  else
    printf '%s\n' "${acquire}"
  fi
done
