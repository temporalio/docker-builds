.ONESHELL:
.PHONY:

all: install

##### Variables ######
MAKEFLAGS += --no-print-directory
COLOR := "\e[1;36m%s\e[0m\n"

TEMPORAL_ROOT := temporal
TCTL_ROOT := tctl

REPO ?= temporalio
IMAGE_TAG ?= sha-$(shell git rev-parse --short HEAD)
TEMPORAL_SHA := $(shell sh -c 'git submodule status -- temporal | cut -c2-40')
TCTL_SHA := $(shell sh -c "git submodule status -- tctl | cut -c2-40")

SERVER_BUILD_ARGS := --build-arg
PLATFORM ?=

##### Scripts ######
install: install-submodules

update: update-submodules

install-submodules:
	@printf $(COLOR) "Installing temporal and tctl submodules..."
	git submodule update --init $(TEMPORAL_ROOT) $(TCTL_ROOT)

update-submodules:
	@printf $(COLOR) "Updatinging temporal and tctl submodules..."
	git submodule update --force --remote $(TEMPORAL_ROOT) $(TCTL_ROOT)

##### Docker #####
simulate-push:
	@act push -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest

COMMIT =?
simulate-dispatch:
	@act workflow-dispatch -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest --input commit=$(COMMIT)

# We hard-code linux/amd64 here as the docker machine for mac doesn't support cross-platform builds (but it does when running verify-ci)
docker-server:
	@printf $(COLOR) "Building docker image temporalio/server:$(IMAGE_TAG)..."
	docker build . -f server.Dockerfile -t $(REPO)/server:$(IMAGE_TAG) $(PLATFORM) --build-arg TEMPORAL_SHA=$(TEMPORAL_SHA) --build-arg TCTL_SHA=$(TCTL_SHA)

docker-admin-tools: docker-server
	@printf $(COLOR) "Build docker image temporalio/admin-tools:$(IMAGE_TAG)..."
	docker build . -f admin-tools.Dockerfile -t $(REPO)/admin-tools:$(IMAGE_TAG) $(PLATFORM) --build-arg SERVER_IMAGE=$(REPO)/server:$(IMAGE_TAG)

docker-auto-setup: docker-admin-tools
	@printf $(COLOR) "Build docker image temporalio/auto-setup:$(IMAGE_TAG)..."
	docker build . -f auto-setup.Dockerfile -t $(REPO)/auto-setup:$(IMAGE_TAG) $(PLATFORM) --build-arg SERVER_IMAGE=$(REPO)/server:$(IMAGE_TAG) --build-arg ADMIN_TOOLS_IMAGE=$(REPO)/admin-tools:$(IMAGE_TAG)

docker-buildx-container:
	docker buildx create --name builder-x --driver docker-container --use

docker-server-x:
	@printf $(COLOR) "Building cross-platform docker image temporalio/server:$(IMAGE_TAG)..."
	make PLATFORM="--platform linux/amd64,linux/arm64" docker-server

docker-admin-tools-x:
	@printf $(COLOR) "Build cross-platform docker image temporalio/admin-tools:$(IMAGE_TAG)..."
	make PLATFORM="--platform linux/amd64,linux/arm64" docker-admin-tools

docker-auto-setup-x:
	@printf $(COLOR) "Build cross-platform docker image temporalio/auto-setup:$(IMAGE_TAG)..."
	make PLATFORM="--platform linux/amd64,linux/arm64" docker-auto-setup

build: docker-auto-setup docker-admin-tools docker-server
buildx: docker-auto-setup-x docker-admin-tools-x docker-server-x

test:
	TEMPORAL_VERSION=$(IMAGE_TAG) test.sh
