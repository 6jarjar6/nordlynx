FROM ghcr.io/linuxserver/baseimage-alpine:3.20@sha256:363101d57c766dbcc9868e1f71d94ef0929a21823381bf1cfc55f7edd4440eeb
LABEL maintainer="6jarjar6"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /
RUN apk add --no-cache -U wireguard-tools curl jq patch iptables && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch
