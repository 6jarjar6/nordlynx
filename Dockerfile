FROM ghcr.io/linuxserver/baseimage-alpine:3.22@sha256:3283323cb6ba168da895f4bd2443148d4e60efaa2fa8c2732aa6f572d5305c8d
LABEL maintainer="6jarjar6"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /

# Install bash
RUN apk add --no-cache -U bash

# Set Bash as the default shell
SHELL ["/bin/bash", "-c"]

RUN chmod +x /etc/cont-init.d/* /etc/services.d/wireguard/* && \
    apk add --no-cache -U wireguard-tools curl jq patch iptables && \
    patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
    rm -rf /tmp/* /patch
