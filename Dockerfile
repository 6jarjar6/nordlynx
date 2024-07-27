FROM ghcr.io/linuxserver/baseimage-alpine:3.20@sha256:3d4c1686f11c91d34a6f83325244e90c131828be530b513eade5c73e0c7fe2e8
LABEL maintainer="6jarjar6"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /

# Install bash
RUN apk add --no-cache -U bash

# Set Bash as the default shell
SHELL ["/bin/bash", "-c"]

# Ensure scripts in /etc/cont-init.d/ and /etc/services.d/wireguard have the correct permissions
RUN chmod +x /etc/cont-init.d/* && chmod +x /etc/services.d/wireguard/*

RUN apk add --no-cache -U wireguard-tools curl jq patch iptables ip6tables && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch
