#!/bin/bash

set -eu
set -o pipefail

PROTO="ftp http https"

CIP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' apt-cacher-ng)

for p in $PROTO; do
  PROXY_ACQUIRE="Acquire::$p { Proxy \"http://$CIP:3142\"; }"
  if [[ -d /etc/apt/apt.conf.d ]]; then
    echo "${PROXY_ACQUIRE}" | \
      sudo tee --append /etc/apt/apt.conf.d/01proxy
  else
    echo "${PROXY_ACQUIRE}"
  fi
done
