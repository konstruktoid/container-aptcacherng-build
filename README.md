# Apt-Cacher NG

[https://www.unix-ag.uni-kl.de/~bloch/acng/](https://www.unix-ag.uni-kl.de/~bloch/acng/)

## Manual build

```sh
docker build --no-cache --tag konstruktoid/apt-cacher-ng:latest -f Dockerfile .
docker run -d --cap-drop=all --name apt-cacher-ng -p 3142:3142 konstruktoid/apt-cacher-ng VerboseLog=1 Debug=7 ForeGround=1 PassThroughPattern=.*
curl -s http://$(docker inspect -f '{{.NetworkSettings.IPAddress}}' apt-cacher-ng):3142/acng-report.html
```

`./apparmor/` contains apparmor profile and toml file, `--security-opt="apparmor:docker-aptcacherng"`

`docker run -d --security-opt="apparmor:docker-aptcacherng" --name apt-cacher-ng -p 3142:3142 konstruktoid/apt-cacher-ng VerboseLog=1 Debug=7 ForeGround=1 PassThroughPattern=.*`

## Autobuild

```sh
docker run -d --restart=always --cap-drop=all --name apt-cacher-ng -p 3142:3142 konstruktoid/apt-cacher-ng VerboseLog=1 Debug=7 ForeGround=1 PassThroughPattern=.*
```

### /etc/apt/apt.conf.d/01proxy

```sh
Acquire::ftp { Proxy "http://172.17.0.2:3142"; }
Acquire::http { Proxy "http://172.17.0.2:3142"; }
Acquire::https { Proxy "http://172.17.0.2:3142"; }
```

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
