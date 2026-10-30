FROM ghcr.io/linuxserver/baseimage-alpine:3.24@sha256:52106d187a66ccb92e3289cb6dd25c549cb0b6b7bfec38a51994434c96db2d35
LABEL maintainer="6jarjar6"

# Healthy if the oldest peer handshake is at most 120s old.
# wg reports latest-handshakes as a human-readable duration ("1 hour ago",
# "never"), not an epoch, so the duration is converted to seconds (age).
# "never" and an empty result (wg0 missing) both fail the check, as they should.
HEALTHCHECK --start-period=60s CMD v="$(/etc/lib/wg_age.sh 2>/dev/null)"; [ -n "$v" ] && [ "$v" -le 120 ] || exit 1

COPY /root /

# Install bash
RUN apk add --no-cache -U bash

# Set Bash as the default shell
SHELL ["/bin/bash", "-c"]

RUN chmod +x /etc/cont-init.d/* /etc/lib/wg_age.sh /etc/services.d/wireguard/* && \
    apk add --no-cache -U wireguard-tools curl jq iptables ip6tables conntrack-tools && \
    apk upgrade && \
    sed -i '/cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1/s/^\(\t\)/\1# /' /usr/bin/wg-quick && \
    rm -rf /tmp/*
