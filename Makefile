.DEFAULT_GOAL := build-container
CADDY_VERSION?="ce0988f48a62bad7e2ca9509311ea77545af27b4"

build:
	docker build . -f Dockerfile.build -t "caddy-build"
	docker run -e CADDY_VERSION=$(CADDY_VERSION) -v "$(PWD)":/target -u $(shell id -u):$(shell id -g) caddy-build:latest

build-container: build
	docker build . -f Dockerfile -t "caddy-run"

run: build-container
	docker run -p 2015:2015 -ti caddy-run:latest

