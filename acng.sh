#!/bin/sh
# Entry point for the apt-cacher-ng container.
#
# exec replaces this shell so apt-cacher-ng runs as PID 1 and receives the
# signals docker/podman send on stop, instead of them being swallowed by /bin/sh.

set -eu

exec /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1 "$@"
