DOCKER_IMAGE_TAG ?= latest
NATIVE_ARCH := $(shell go env GOARCH)

##### docker build #####
base-admin-tools:
	docker build -f base-admin-tools.Dockerfile -t temporalio/base-admin-tools:$(DOCKER_IMAGE_TAG) .

base-builder:
	docker build -f base-builder.Dockerfile -t temporalio/base-builder:$(DOCKER_IMAGE_TAG) .

base-server:
	docker build -f base-server.Dockerfile -t temporalio/base-server:$(DOCKER_IMAGE_TAG) .

base-ci-builder:
	docker build -f base-ci-builder.Dockerfile -t temporalio/base-ci-builder:$(DOCKER_IMAGE_TAG) .

base-runtime-hardened:
	docker build -f base-runtime-hardened.Dockerfile -t temporaliotest/base-runtime-hardened:$(DOCKER_IMAGE_TAG) .

base-admin-tools-hardened:
	docker build -f base-admin-tools-hardened.Dockerfile -t temporaliotest/base-admin-tools-hardened:$(DOCKER_IMAGE_TAG) .

##### docker buildx #####
docker-buildx-container:
	docker buildx create --name builder-x --driver docker-container --use

base-admin-tools-x:
	docker buildx build . -f base-admin-tools.Dockerfile -t temporalio/base-admin-tools:$(DOCKER_IMAGE_TAG) --platform linux/$(NATIVE_ARCH) --load

base-builder-x:
	docker buildx build . -f base-builder.Dockerfile -t temporalio/base-builder:$(DOCKER_IMAGE_TAG) --platform linux/$(NATIVE_ARCH) --load

base-server-x:
	docker buildx build . -f base-server.Dockerfile -t temporalio/base-server:$(DOCKER_IMAGE_TAG) --platform linux/$(NATIVE_ARCH) --load

base-ci-builder-x:
	docker buildx build . -f base-ci-builder.Dockerfile -t temporalio/base-ci-builder:$(DOCKER_IMAGE_TAG) --platform linux/$(NATIVE_ARCH) --load

base-runtime-hardened-x:
	docker buildx build . -f base-runtime-hardened.Dockerfile -t temporaliotest/base-runtime-hardened:$(DOCKER_IMAGE_TAG) --platform linux/$(NATIVE_ARCH) --load

base-admin-tools-hardened-x:
	docker buildx build . -f base-admin-tools-hardened.Dockerfile -t temporaliotest/base-admin-tools-hardened:$(DOCKER_IMAGE_TAG) --platform linux/$(NATIVE_ARCH) --load
