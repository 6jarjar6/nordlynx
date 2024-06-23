FROM ghcr.io/linuxserver/baseimage-alpine:3.17@sha256:cb06bc8d2ed9aa7cf3ff934bdee38fff95d9902b9095acfb5054fbf815fd6c75
LABEL maintainer="6jarjar6"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /
RUN apk add --no-cache -U wireguard-tools curl jq patch iptables && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch
