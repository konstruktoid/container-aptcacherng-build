# Apt-Cacher NG

[https://www.unix-ag.uni-kl.de/~bloch/acng/](https://www.unix-ag.uni-kl.de/~bloch/acng/)

## Usage

```sh
docker run -d --cap-drop=all --name apt-cacher-ng -p 3142:3142 konstruktoid/apt-cacher-ng VerboseLog=1 Debug=7 PassThroughPattern=.*
curl -s 127.0.0.1:3142/acng-report.html
```

### Manual build

```sh
docker build --no-cache --tag konstruktoid/apt-cacher-ng:latest -f Dockerfile .
docker run -d --cap-drop=all --name apt-cacher-ng -p 3142:3142 konstruktoid/apt-cacher-ng VerboseLog=1 Debug=7 PassThroughPattern=.*
curl -s 127.0.0.1:3142/acng-report.html
```

### Example /etc/apt/apt.conf.d/01proxy script

```sh
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
```
