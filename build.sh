#!/bin/sh

set -eux

SOURCE_DIR=${SOURCE_DIR:=""}

CADDY_VERSION=${CADDY_VERSION:="ce0988f48a62bad7e2ca9509311ea77545af27b4"}
CADDY_BUILD_VERSION=${CADDY_BUILD_VERSION:="c62e2219460a8828970dad09212c3a4cec40b56c"}

mkdir -p /tmp/go /target/.cache
export GOPATH=/tmp/go
export GOCACHE=/target/.cache

if [ -z "$SOURCE_DIR" ]; then
  go get github.com/mholt/caddy/caddy
  cd "$GOPATH/src/github.com/mholt/caddy" && git checkout "$CADDY_VERSION" && git submodule update --init --recursive
else
  test -d "$SOURCE_DIR/caddy" || (echo "Source code not found"; false)
  mkdir -p "$GOPATH/src/github.com/mholt"
  ln -s "$SOURCE_DIR" "$GOPATH/src/github.com/mholt/caddy"
fi

go get github.com/caddyserver/builds
cd "$GOPATH/src/github.com/caddyserver/builds" && git checkout $CADDY_BUILD_VERSION && git submodule update --init --recursive

cd "$GOPATH/src/github.com/mholt/caddy/caddy"

# This is hacky, I don't like that
sed -i ./caddymain/run.go -e 's#^var EnableTelemetry = true$#var EnableTelemetry = false#'
grep '^var EnableTelemetry = false$' ./caddymain/run.go || (echo "Failed to disable telemetry"; false)

go run build.go

cp "./caddy" /target