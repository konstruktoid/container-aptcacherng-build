FROM ubuntu:noble@sha256:33ceb71981b602c1a7443a53469e4dba065f7503eab3078a2d7a57a2ab987517

LABEL org.opencontainers.image.title="apt-cacher-ng" \
      org.opencontainers.image.description="Apt-Cacher NG caching proxy for Debian/Ubuntu package repositories" \
      org.opencontainers.image.authors="Thomas Sjögren <konstruktoid@users.noreply.github.com>" \
      org.opencontainers.image.source="https://github.com/konstruktoid/container-aptcacherng-build" \
      org.opencontainers.image.url="https://www.unix-ag.uni-kl.de/~bloch/acng/" \
      org.opencontainers.image.base.name="docker.io/library/ubuntu:noble"

ARG DEBIAN_FRONTEND=noninteractive
ENV ACNG_USER=apt-cacher-ng

# Owned by root and only readable/executable by others, so the unprivileged
# runtime user cannot rewrite its own entry point.
COPY --chmod=0555 ./acng.sh /acng.sh

# universe is enabled by default in the official noble image, so no sources
# rewriting is needed to reach apt-cacher-ng.
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends \
      apt-cacher-ng \
      ca-certificates \
      curl && \
    mkdir -p /var/log/apt-cacher-ng /var/cache/apt-cacher-ng /var/run/apt-cacher-ng && \
    chown -R "${ACNG_USER}:${ACNG_USER}" \
      /var/cache/apt-cacher-ng \
      /var/log/apt-cacher-ng \
      /var/run/apt-cacher-ng && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
  CMD ["curl", "--fail", "--silent", "--show-error", "http://127.0.0.1:3142/acng-report.html"]

VOLUME ["/var/cache/apt-cacher-ng"]
EXPOSE 3142

USER $ACNG_USER

ENTRYPOINT ["/acng.sh"]
CMD ["VerboseLog=1", "Debug=7", "PassThroughPattern=.*"]
