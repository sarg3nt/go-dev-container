IMAGE_NAME := ghcr.io/sarg3nt/go-dev-container
IMAGE_TAG := 1.0.4
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD | sed 's/[\/_]/-/g')
CURRENT_DIR := $(shell pwd)

.PHONY: build
build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)-$(GIT_BRANCH)" .

.PHONY: run
run:
	docker run --mount type=bind,source="${CURRENT_DIR}",target=/workspaces/working \
		-w /workspaces/working -it --rm -u "vscode" \
		"$(IMAGE_NAME):$(IMAGE_TAG)-$(GIT_BRANCH)" zsh

.PHONY: push
push: 
	docker push "$(IMAGE_NAME):$(IMAGE_TAG)-$(GIT_BRANCH)"