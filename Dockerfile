FROM alpine:3.8

COPY caddy /usr/bin
WORKDIR /caddy
COPY index.html /caddy/index.html

ENTRYPOINT caddy
