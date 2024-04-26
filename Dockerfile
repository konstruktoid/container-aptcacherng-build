FROM ubuntu:noble

ENV USER apt-cacher-ng

LABEL \
    org.label-schema.name="AptCacherNG" \
    org.labelschema.url="https://www.unix-ag.uni-kl.de/~bloch/acng/" \
    org.labelschema.vcs-url="git@github.com:konstruktoid/container-aptcacherng-build.git"

COPY ./acng.sh /acng.sh

RUN \
    sed -i 's/main/main universe/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install apt-cacher-ng \
      ca-certificates curl --no-install-recommends && \
    apt-get -y clean && \
    mkdir -p /var/log/apt-cacher-ng /var/cache/apt-cacher-ng && \
    chmod 0700 /acng.sh && \
    chown -R $USER:$USER /acng.sh /var/cache/apt-cacher-ng \
      /var/log/apt-cacher-ng /var/run/apt-cacher-ng && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo

HEALTHCHECK --interval=5m --timeout=3s \
   CMD curl -f http://127.0.0.1:3142/acng-report.html || exit 1

VOLUME ["/var/cache/apt-cacher-ng"]
EXPOSE 3142

USER $USER

ENTRYPOINT ["/acng.sh"]
CMD ["VerboseLog=1","Debug=7","ForeGround=1","PassThroughPattern=.*"]
