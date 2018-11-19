.PHONY: build clean run all container
all: build container

CADDY_VERSION?="ce0988f48a62bad7e2ca9509311ea77545af27b4"
SOURCE_DIR:=""
GIT_HASH := $(shell git rev-parse --short HEAD)
TIMESTAMP := $(shell date +%s)

.build-container.image: Dockerfile.build build.sh
	$(eval IMAGE_LABEL := "caddy-build:$(GIT_HASH)-$(TIMESTAMP)")
	docker build . -f Dockerfile.build -t "$(IMAGE_LABEL)" && echo "$(IMAGE_LABEL)" > .build-container.image

caddy: .build-container.image
	$(eval IMAGE_LABEL := $(shell cat .build-container.image))
	docker run -e CADDY_VERSION=$(CADDY_VERSION) -v "$(PWD)":/target -u $(shell id -u):$(shell id -g) -e SOURCE_DIR=${SOURCE_DIR} "$(IMAGE_LABEL)"

.run-container.image: caddy Dockerfile index.html
	$(eval IMAGE_LABEL := "caddy-run:$(GIT_HASH)-$(TIMESTAMP)")
	docker build . -f Dockerfile -t $(IMAGE_LABEL) && echo "$(IMAGE_LABEL)" > .run-container.image

build: caddy
container: .run-container.image

run: container
	$(eval IMAGE_LABEL := $(shell cat .run-container.image))
	docker run -p 8080:8080 -ti $(IMAGE_LABEL) -port 8080

clean:
	@rm -f caddy
	@rm -f .*.image
	@rm -fr .gocache
	@rm -fr .gopath
