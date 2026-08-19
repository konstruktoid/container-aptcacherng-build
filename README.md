# Apt-Cacher NG

[Apt-Cacher NG](https://www.unix-ag.uni-kl.de/~bloch/acng/) is a caching proxy
for Debian and Ubuntu package repositories.

## Usage

The image runs as the unprivileged `apt-cacher-ng` user, so it needs no added
capabilities.

```sh
docker run -d --cap-drop=all --name apt-cacher-ng -p 3142:3142 \
  -v acng-cache:/var/cache/apt-cacher-ng \
  konstruktoid/apt-cacher-ng VerboseLog=1 Debug=7 PassThroughPattern=.*
curl -s 127.0.0.1:3142/acng-report.html
```

`ForeGround=1` is set by the entry point, so it does not need to be passed as an
argument. Anything you do pass replaces the default
`VerboseLog=1 Debug=7 PassThroughPattern=.*`.

The cached packages live in the `/var/cache/apt-cacher-ng` volume; without a
named volume they are discarded with the container.

### Manual build

```sh
docker build --no-cache --tag konstruktoid/apt-cacher-ng:latest -f Dockerfile .
```

### Health check

The `HEALTHCHECK` fetches the status report:

```sh
curl --fail http://127.0.0.1:3142/acng-report.html
```

### Pointing apt at the cache

`aptProxy.sh` reads the container's address with `docker inspect` and writes
the matching `Acquire::*::Proxy` lines to `/etc/apt/apt.conf.d/01proxy`. That
file is replaced rather than appended to, so rerunning it after the container
has been recreated does not leave the previous address behind. It needs
`docker` and, to write that file, `sudo`:

```sh
./aptProxy.sh              # defaults to the container named apt-cacher-ng
./aptProxy.sh my-container
```

If `/etc/apt/apt.conf.d` does not exist the lines are printed instead of
written, so the script is safe to run on a non-Debian host to see what it would
do.

## AppArmor

`./apparmor/` contains an AppArmor profile and its toml source, applied with
`--security-opt="apparmor:docker-aptcacherng"`.

## Development

`.pre-commit-config.yaml` runs gitleaks, hadolint, shellcheck, actionlint
and markdownlint:

```sh
pre-commit run --all-files
```

Dependabot keeps the action pins and the base image digest current. It does not
cover the hook revisions above, so refresh those with `pre-commit autoupdate`.
