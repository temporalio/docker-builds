.PHONY:

all: install

##### Variables ######
COLOR := "\e[1;36m%s\e[0m\n"

# Disable cgo by default.
CGO_ENABLED ?= 0

TEMPORAL_ROOT := temporal
TCTL_ROOT := tctl
CLI_ROOT := cli
DOCKERIZE_ROOT := dockerize
IMAGE_TAG ?= sha-$(shell git rev-parse --short HEAD)
TEMPORAL_SHA := $(shell sh -c 'git submodule status -- temporal | cut -c2-40')
TCTL_SHA := $(shell sh -c "git submodule status -- tctl | cut -c2-40")

DOCKER ?= docker buildx
BAKE := IMAGE_TAG=$(IMAGE_TAG) TEMPORAL_SHA=$(TEMPORAL_SHA) TCTL_SHA=$(TCTL_SHA) $(DOCKER) bake
NATIVE_ARCH := $(shell go env GOARCH)

##### Scripts ######
install: install-submodules
clean:
	rm -rf ./build

update: update-submodules

install-submodules:
	@printf $(COLOR) "Installing submodules..."
	git submodule update --init

update-submodules:
	@printf $(COLOR) "Updatinging temporal and tctl submodules..."
	git submodule update --force --remote $(TEMPORAL_ROOT) $(TCTL_ROOT)

##### Docker #####
build/%:
	mkdir -p $(@)

build/%/dockerize:
	@printf $(COLOR) "Building dockerize with CGO_ENABLED=$(CGO_ENABLED) for linux/$*..."
	cd $(DOCKERIZE_ROOT) && CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=$* go build -o $@ .

# If you're new to Make, this is a pattern rule: https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html#Pattern-Rules
# $* expands to the stem that matches the %, so when the target is amd64-bins $* expands to amd64
%-bins: build/% build/%/dockerize
	@GOOS=linux GOARCH=$* CGO_ENABLED=$(CGO_ENABLED) make -C $(TEMPORAL_ROOT) bins
	@cp $(TEMPORAL_ROOT)/temporal-server build/$*/
	@cp $(TEMPORAL_ROOT)/temporal-cassandra-tool build/$*/
	@cp $(TEMPORAL_ROOT)/temporal-sql-tool build/$*/
	@cp $(TEMPORAL_ROOT)/tdbg build/$*/
	@GOOS=linux GOARCH=$* CGO_ENABLED=$(CGO_ENABLED) make -C $(CLI_ROOT) build
	@cp ./$(CLI_ROOT)/temporal build/$*/
	@GOOS=linux GOARCH=$* CGO_ENABLED=$(CGO_ENABLED) make -C $(TCTL_ROOT) build
	@cp ./$(TCTL_ROOT)/tctl build/$*/
	@cp ./$(TCTL_ROOT)/tctl-authorization-plugin build/$*/

bins: install-submodules amd64-bins arm64-bins
.NOTPARALLEL: bins

simulate-push:
	@act push -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest

COMMIT =?
simulate-dispatch:
	@act workflow_dispatch -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest --input commit=$(COMMIT)

# We hard-code the native arch here as the docker machine for mac doesn't support cross-platform builds (unless running within act)
build: docker-server docker-admin-tools docker-auto-setup
	$(BAKE) --set "*.platform=linux/$(NATIVE_ARCH)" --load

docker-server: $(NATIVE_ARCH)-bins
	@printf $(COLOR) "Building docker image temporalio/server:$(IMAGE_TAG)..."
	$(BAKE) server --set "*.platform=linux/$(NATIVE_ARCH)"

docker-admin-tools: $(NATIVE_ARCH)-bins
	@printf $(COLOR) "Build docker image temporalio/admin-tools:$(IMAGE_TAG)..."
	$(BAKE) admin-tools --set "*.platform=linux/$(NATIVE_ARCH)"

docker-auto-setup: $(NATIVE_ARCH)-bins
	@printf $(COLOR) "Build docker image temporalio/auto-setup:$(IMAGE_TAG)..."
	$(BAKE) auto-setup --set "*.platform=linux/$(NATIVE_ARCH)"

docker-buildx-container:
	docker buildx create --name builder-x --driver docker-container --use

docker-server-x: bins
	@printf $(COLOR) "Building cross-platform docker image temporalio/server:$(IMAGE_TAG)..."
	$(BAKE) server

docker-admin-tools-x: bins
	@printf $(COLOR) "Build cross-platform docker image temporalio/admin-tools:$(IMAGE_TAG)..."
	$(BAKE) admin-tools

docker-auto-setup-x: bins
	@printf $(COLOR) "Build cross-platform docker image temporalio/auto-setup:$(DOCKER_IMAGE_TAG)..."
	$(BAKE) auto-setup

test:
	IMAGE_TAG=$(IMAGE_TAG) ./test.sh
