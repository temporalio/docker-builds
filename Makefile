.ONESHELL:
.PHONY:

all: install

##### Variables ######
COLOR := "\e[1;36m%s\e[0m\n"

TEMPORAL_ROOT := temporal
TCTL_ROOT := tctl
IMAGE_TAG ?= sha-$(shell git rev-parse --short HEAD)
TEMPORAL_SHA := $(shell sh -c 'git submodule status -- temporal | cut -c2-40')
TCTL_SHA := $(shell sh -c "git submodule status -- tctl | cut -c2-40")

DOCKER ?= docker buildx
BAKE := IMAGE_TAG=$(IMAGE_TAG) TEMPORAL_SHA=$(TEMPORAL_SHA) TCTL_SHA=$(TCTL_SHA) $(DOCKER) bake

AMD64_BINS ?= build/amd64
ARM64_BINS ?= build/arm64

##### Scripts ######
install: install-submodules

update: update-submodules

install-submodules:
	@printf $(COLOR) "Installing submodules..."
	git submodule update --init

update-submodules:
	@printf $(COLOR) "Updating submodules..."
	git submodule update --force --remote $(TEMPORAL_ROOT) $(TCTL_ROOT)

##### Docker #####
$(AMD64_BINS):
	mkdir -p $(@)

$(ARM64_BINS):
	mkdir -p $(@)

amd64-bins: $(AMD64_BINS)
	@printf $(COLOR) "Compiling for amd64..."
	(cd dockerize && GOOS=linux GOARCH=arm64 go build -o ../$(AMD64_BINS)/dockerize .)
	GOOS=linux GOARCH=amd64 make -C temporal bins
	cp temporal/{temporal-server,temporal-cassandra-tool,temporal-sql-tool,tdbg} $(AMD64_BINS)
	GOOS=linux GOARCH=amd64 make -C cli build
	cp ./cli/temporal $(AMD64_BINS)/
	GOOS=linux GOARCH=amd64 make -C tctl build
	cp ./tctl/tctl $(AMD64_BINS)/
	cp ./tctl/tctl-authorization-plugin $(AMD64_BINS)/

arm64-bins: $(ARM64_BINS)
	@printf $(COLOR) "Compiling for arm64..."
	(cd dockerize && GOOS=linux GOARCH=arm64 go build -o ../$(ARM64_BINS)/dockerize .)
	GOOS=linux GOARCH=arm64 make -C temporal bins
	cp temporal/{temporal-server,temporal-cassandra-tool,temporal-sql-tool,tdbg} $(ARM64_BINS)
	GOOS=linux GOARCH=arm64 make -C cli build
	cp ./cli/temporal $(ARM64_BINS)/
	GOOS=linux GOARCH=arm64 make -C tctl build
	cp ./tctl/tctl $(ARM64_BINS)/
	cp ./tctl/tctl-authorization-plugin $(ARM64_BINS)/

bins: install-submodules amd64-bins arm64-bins
.NOTPARALLEL: bins

build: bins
	$(BAKE)

simulate-push:
	@act push -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest

COMMIT =?
simulate-dispatch:
	@act workflow_dispatch -s GITHUB_TOKEN="$(shell gh auth token)" -j build-push-images -P ubuntu-latest-16-cores=catthehacker/ubuntu:act-latest --input commit=$(COMMIT)

# We hard-code linux/amd64 here as the docker machine for mac doesn't support cross-platform builds (but it does when running verify-ci)
docker-server:
	@printf $(COLOR) "Building docker image temporalio/server:$(IMAGE_TAG)..."
	$(BAKE) server --set "*.platform=linux/amd64"

docker-admin-tools:
	@printf $(COLOR) "Build docker image temporalio/admin-tools:$(IMAGE_TAG)..."
	$(BAKE) admin-tools --set "*.platform=linux/amd64"

docker-auto-setup:
	@printf $(COLOR) "Build docker image temporalio/auto-setup:$(IMAGE_TAG)..."
	$(BAKE) auto-setup --set "*.platform=linux/amd64"

docker-buildx-container:
	docker buildx create --name builder-x --driver docker-container --use

docker-server-x:
	@printf $(COLOR) "Building cross-platform docker image temporalio/server:$(IMAGE_TAG)..."
	$(BAKE) server

docker-admin-tools-x:
	@printf $(COLOR) "Build cross-platform docker image temporalio/admin-tools:$(IMAGE_TAG)..."
	$(BAKE) admin-tools

docker-auto-setup-x:
	@printf $(COLOR) "Build cross-platform docker image temporalio/auto-setup:$(DOCKER_IMAGE_TAG)..."
	$(BAKE) auto-setup

test:
	IMAGE_TAG=$(IMAGE_TAG) ./test.sh
