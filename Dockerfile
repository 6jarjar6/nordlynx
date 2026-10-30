FROM ghcr.io/linuxserver/baseimage-alpine:3.24@sha256:52106d187a66ccb92e3289cb6dd25c549cb0b6b7bfec38a51994434c96db2d35
LABEL maintainer="6jarjar6"

# Healthy iff the most-stale peer handshake is at most 120s old.
# wg emits latest-handshakes as a human-readable duration ("1 hour ago",
# "never"), not an epoch, so the duration is converted to seconds (age).
# "never" and an empty result (wg0 missing) both fail the check, as they should.
HEALTHCHECK CMD v="$(wg show wg0 latest-handshakes 2>/dev/null | awk 'NF==0{next}{t=0;n="";u["second"]=1;u["sec"]=1;u["seconds"]=1;u["minute"]=60;u["min"]=60;u["minutes"]=60;u["mins"]=60;u["hour"]=3600;u["hours"]=3600;u["day"]=86400;u["days"]=86400;u["week"]=604800;u["weeks"]=604800;u["month"]=2592000;u["months"]=2592000;u["year"]=31536000;u["years"]=31536000;for(i=1;i<=NF;i++){if($i=="never"){t=999999999}else if($i~/^[0-9]+$/){n=$i}else if(($i in u)&&n!=""){t+=n*u[$i];n="";}}print t}' | sort -rn | head -1)"; [ -n "$v" ] && [ "$v" -le 120 ] || exit 1
HEALTHCHECK START_PERIOD 60s

COPY /root /

# Install bash
RUN apk add --no-cache -U bash

# Set Bash as the default shell
SHELL ["/bin/bash", "-c"]

RUN chmod +x /etc/cont-init.d/* /etc/services.d/wireguard/* && \
    apk add --no-cache -U wireguard-tools curl jq iptables ip6tables conntrack-tools && \
    apk upgrade && \
    sed -i '/cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1/s/^\(\t\)/\1# /' /usr/bin/wg-quick && \
    rm -rf /tmp/*
