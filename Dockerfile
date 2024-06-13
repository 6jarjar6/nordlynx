FROM ghcr.io/linuxserver/baseimage-alpine:3.20@sha256:878be68663918e0a6fa7d7f0a29f6d6975cb3907198b94c0e846f430d9907c8c
LABEL maintainer="6jarjar6"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /
RUN apk add --no-cache -U wireguard-tools curl jq patch iptables ip6tables && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch
