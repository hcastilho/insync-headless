FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG INSYNC_VERSION=3.2.7.10758
ARG INSYNC_DEB_URL=https://cdn.insynchq.com/builds/linux/${INSYNC_VERSION}/insync-headless_${INSYNC_VERSION}-buster_amd64.deb

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -L -o /tmp/insync-headless.deb "${INSYNC_DEB_URL}" && \
    apt-get install -y /tmp/insync-headless.deb && \
    rm /tmp/insync-headless.deb && \
    apt-get purge -y curl && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

USER ubuntu
ENTRYPOINT ["/entrypoint.sh"]
