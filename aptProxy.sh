#!/bin/sh
PROTO="http https"
IPA=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

echo "# Proxies added $(date) " | sudo tee /etc/apt/apt.conf.d/01proxy

for p in $PROTO; do
  echo "Acquire::$p::Proxy \"http://$IPA:3142\";" | sudo tee --append /etc/apt/apt.conf.d/01proxy
done
