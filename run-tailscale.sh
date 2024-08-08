#!/usr/bin/env bash

/root/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
PID=$!

/root/tailscale up --advertise-exit-node &
/root/tailscale web --listen 0.0.0.0:80 &

export ALL_PROXY=socks5://localhost:1055/
tailscale_ip=$(/root/tailscale ip)
echo "Tailscale is up at IP ${tailscale_ip}"

wait ${PID}