all: install

##### Variables ######
COLOR := "\e[1;36m%s\e[0m\n"

# Disable cgo by default.
CGO_ENABLED ?= 0

TEMPORAL_ROOT := temporal
TCTL_ROOT := tctl
CLI_ROOT := cli
TEMPORAL_SHA := $(shell sh -c 'git submodule status -- temporal | cut -c2-41')
TCTL_SHA := $(shell sh -c "git submodule status -- tctl | cut -c2-41")

IMAGE_SHA_TAG ?= sha-$(shell git rev-parse --short HEAD)
IMAGE_BRANCH_TAG ?= branch-$(shell git rev-parse --abbrev-ref HEAD)

DOCKER ?= docker buildx
DOCKER_BUILDX_CACHE_FROM ?=
DOCKER_BUILDX_CACHE_TO ?=
BAKE := IMAGE_SHA_TAG=$(IMAGE_SHA_TAG) \
		IMAGE_BRANCH_TAG=$(IMAGE_BRANCH_TAG) \
		TEMPORAL_SHA=$(TEMPORAL_SHA) \
		TCTL_SHA=$(TCTL_SHA) \
		DOCKER_BUILDX_CACHE_FROM=$(DOCKER_BUILDX_CACHE_FROM) \
		DOCKER_BUILDX_CACHE_TO=$(DOCKER_BUILDX_CACHE_TO) \
		$(DOCKER) bake
NATIVE_ARCH := $(shell go env GOARCH)

# Default to loading into the local docker context. Provide the value 'registry' if you wish to push the images
BAKE_OUTPUT ?= docker

##### Scripts ######
.PHONY: install
install: install-submodules
clean:
	rm -rf ./build

.PHONY: update
update: update-submodules

.PHONY: install-submodules
install-submodules:
	@printf $(COLOR) "Installing submodules..."
	git submodule update --init

.PHONY: update-submodules
update-submodules:
	@printf $(COLOR) "Updating temporal and tctl submodules..."
	git submodule update --force --remote $(TEMPORAL_ROOT) $(TCTL_ROOT)

##### Docker #####

# If you're new to Make, this is a pattern rule: https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html#Pattern-Rules
# $* expands to the stem that matches the %, so when the target is amd64-bins $* expands to amd64
%-bins:
	@mkdir -p build/$*
	@GOOS=linux GOARCH=$* CGO_ENABLED=$(CGO_ENABLED) make -C $(TEMPORAL_ROOT) clean-bins bins
	@cp $(TEMPORAL_ROOT)/temporal-server build/$*/
	@cp $(TEMPORAL_ROOT)/temporal-cassandra-tool build/$*/
	@cp $(TEMPORAL_ROOT)/temporal-sql-tool build/$*/
	@cp $(TEMPORAL_ROOT)/tdbg build/$*/
	@cd $(CLI_ROOT) && GOOS=linux GOARCH=$* CGO_ENABLED=$(CGO_ENABLED) go build ./cmd/temporal
	@cp ./$(CLI_ROOT)/temporal build/$*/
	@GOOS=linux GOARCH=$* CGO_ENABLED=$(CGO_ENABLED) make -C $(TCTL_ROOT) build
	@cp ./$(TCTL_ROOT)/tctl build/$*/
	@cp ./$(TCTL_ROOT)/tctl-authorization-plugin build/$*/

.PHONY: bins
.NOTPARALLEL: bins
bins: install-submodules amd64-bins arm64-bins

.PHONY: simulate-push
simulate-push:
	@act push -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest

COMMIT =?
.PHONY: simulate-dispatch
simulate-dispatch:
	@act workflow_dispatch -s GITHUB_TOKEN="$(shell gh auth token)" -j build-image -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest --input commit=$(COMMIT)

# We hard-code the native arch here as the docker machine for mac doesn't support cross-platform builds (unless running within act)
# This target also ignores the BAKE_OUTPUT variable to prevent us from uploading a single-architecture image
.PHONY: build-native
build-native: $(NATIVE_ARCH)-bins
	$(BAKE) --set "*.platform=linux/$(NATIVE_ARCH)" --load

.PHONY: build
build: bins
	$(BAKE) --set="*.output=type=$(BAKE_OUTPUT)"

.PHONY: docker-server
docker-server: $(NATIVE_ARCH)-bins
	@printf $(COLOR) "Building docker image temporalio/server:$(IMAGE_SHA_TAG)..."
	$(BAKE) server --set "*.platform=linux/$(NATIVE_ARCH)"

.PHONY: docker-admin-tools
docker-admin-tools: $(NATIVE_ARCH)-bins
	@printf $(COLOR) "Build docker image temporalio/admin-tools:$(IMAGE_SHA_TAG)..."
	$(BAKE) admin-tools --set "*.platform=linux/$(NATIVE_ARCH)"

.PHONY: docker-auto-setup
docker-auto-setup: $(NATIVE_ARCH)-bins
	@printf $(COLOR) "Build docker image temporalio/auto-setup:$(IMAGE_SHA_TAG)..."
	$(BAKE) auto-setup --set "*.platform=linux/$(NATIVE_ARCH)"

.PHONY: docker-buildx-container
docker-buildx-container:
	docker buildx create --name builder-x --driver docker-container --use

.PHONY: docker-server-x
docker-server-x: bins
	@printf $(COLOR) "Building cross-platform docker image temporalio/server:$(IMAGE_SHA_TAG)..."
	$(BAKE) server

.PHONY: docker-admin-tools-x
docker-admin-tools-x: bins
	@printf $(COLOR) "Build cross-platform docker image temporalio/admin-tools:$(IMAGE_SHA_TAG)..."
	$(BAKE) admin-tools

.PHONY: docker-auto-setup-x
docker-auto-setup-x: bins
	@printf $(COLOR) "Build cross-platform docker image temporalio/auto-setup:$(DOCKER_IMAGE_SHA_TAG)..."
	$(BAKE) auto-setup

.PHONY: test
test:
	IMAGE_SHA_TAG=$(IMAGE_SHA_TAG) ./scripts/test.sh

.PHONY: update-tool-submodules
update-tool-submodules:
	./scripts/update-tool-submodules.sh cli
	./scripts/update-tool-submodules.sh tctl

.PHONY: update-alpine
update-alpine:
	@printf $(COLOR) "Updating base images to latest the latest Alpine image..."
	./scripts/update-alpine.sh

.PHONY: update-base-images
update-base-images:
	@printf $(COLOR) "Updating builds to use latest Temporal base images.."
	./scripts/update-base-images.sh
