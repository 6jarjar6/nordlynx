FROM ghcr.io/linuxserver/baseimage-alpine:3.21@sha256:a0b4e66f1c007a543043d2c933f67cc57f9e0dd5d880fb27d0feb6d33124de4b
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
