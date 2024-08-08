FROM debian:latest
WORKDIR /root

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

RUN apt-get -qq update \
  && apt-get -qq install --upgrade -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    netcat-openbsd \
    wget \
    dnsutils \
  > /dev/null \
  && apt-get -qq clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
  && :

RUN echo "+search +short" > /root/.digrc

RUN TAILSCALE_VERSION=${TAILSCALE_VERSION:-1.70.0} \
    && TS_FILE=tailscale_${TAILSCALE_VERSION}_amd64.tgz \
    && wget -q "https://pkgs.tailscale.com/stable/${TS_FILE}" && tar xzf "${TS_FILE}" --strip-components=1 \
    && mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

EXPOSE 80

CMD /root/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 & \
    && /root/tailscale up --advertise-exit-node & \
    && /root/tailscale web --listen 0.0.0.0:80 &