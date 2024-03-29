.ONESHELL:
.PHONY:

all: install

##### Variables ######
COLOR := "\e[1;36m%s\e[0m\n"

# Pass "registry" to automatically push image to the docker hub.
DOCKER_BUILDX_OUTPUT ?= image
IMAGE_TAG ?= sha-$(shell git rev-parse --short HEAD)

TEMPORAL_ROOT := temporal
TCTL_ROOT := tctl
IMAGE_REPO ?= temporaliotest

TEMPORAL_SHA := $(shell sh -c 'git submodule status -- temporal | cut -c2-40')
TCTL_SHA := $(shell sh -c "git submodule status -- tctl | cut -c2-40")
SERVER_BUILD_ARGS := --build-arg TEMPORAL_SHA=$(TEMPORAL_SHA) --build-arg TCTL_SHA=$(TCTL_SHA)

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
docker-server:
	@printf $(COLOR) "Building docker image $(IMAGE_REPO)/server:$(IMAGE_TAG)..."
	docker build . -f server.Dockerfile -t $(IMAGE_REPO)/server:$(IMAGE_TAG) $(SERVER_BUILD_ARGS)

docker-admin-tools: docker-server
	@printf $(COLOR) "Build docker image $(IMAGE_REPO)/admin-tools:$(IMAGE_TAG)..."
	docker build . -f admin-tools.Dockerfile -t $(IMAGE_REPO)/admin-tools:$(IMAGE_TAG) --build-arg SERVER_IMAGE=$(IMAGE_REPO)/server:$(IMAGE_TAG)

docker-auto-setup: docker-admin-tools
	@printf $(COLOR) "Build docker image $(IMAGE_REPO)/auto-setup:$(IMAGE_TAG)..."
	docker build . -f auto-setup.Dockerfile -t $(IMAGE_REPO)/auto-setup:$(IMAGE_TAG) --build-arg SERVER_IMAGE=$(IMAGE_REPO)/server:$(IMAGE_TAG) --build-arg ADMIN_TOOLS_IMAGE=$(IMAGE_REPO)/admin-tools:$(IMAGE_TAG)

docker-buildx-container:
	docker buildx create --name builder-x --driver docker-container --use

docker-server-x:
	@printf $(COLOR) "Building cross-platform docker image $(IMAGE_REPO)/server:$(IMAGE_TAG)..."
	docker buildx build . -f server.Dockerfile -t $(IMAGE_REPO)/server:$(IMAGE_TAG) --platform linux/amd64,linux/arm64 --output type=$(DOCKER_BUILDX_OUTPUT) $(SERVER_BUILD_ARGS)

docker-admin-tools-x: docker-server-x
	@printf $(COLOR) "Build cross-platform docker image $(IMAGE_REPO)/admin-tools:$(IMAGE_TAG)..."
	docker buildx build . -f admin-tools.Dockerfile -t $(IMAGE_REPO)/admin-tools:$(IMAGE_TAG) --platform linux/amd64,linux/arm64 --output type=$(DOCKER_BUILDX_OUTPUT) --build-arg SERVER_IMAGE=$(IMAGE_REPO)/server:$(IMAGE_TAG)

docker-auto-setup-x: docker-admin-tools-x
	@printf $(COLOR) "Build cross-platform docker image $(IMAGE_REPO)/auto-setup:$(IMAGE_TAG)..."
	docker buildx build . -f auto-setup.Dockerfile -t $(IMAGE_REPO)/auto-setup:$(IMAGE_TAG) --platform linux/amd64,linux/arm64 --output type=$(DOCKER_BUILDX_OUTPUT) --build-arg SERVER_IMAGE=$(IMAGE_REPO)/server:$(IMAGE_TAG) --build-arg ADMIN_TOOLS_IMAGE=$(IMAGE_REPO)/admin-tools:$(IMAGE_TAG)
