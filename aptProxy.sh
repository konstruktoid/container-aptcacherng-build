#!/bin/sh
PROTO="ftp http https"
echo "# Proxies added $(date) " | sudo tee /etc/apt/apt.conf.d/01proxy

CIP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' apt-cacher-ng)

for p in $PROTO; do
  echo "Acquire::$p::Proxy \"http://$CIP:3142\";" | \
    sudo tee --append /etc/apt/apt.conf.d/01proxy
done
