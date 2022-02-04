.ONESHELL:
.PHONY:

all: install

##### Variables ######
COLOR := "\e[1;36m%s\e[0m\n"

##### Scripts ######
install: install-submodules

update: update-submodules

install-submodules:
	@printf $(COLOR) "Installing temporal and tctl submodules..."
	git submodule update --init $(PROTO_ROOT)

update-submodules:
	@printf $(COLOR) "Updatinging temporal and tctl submodules..."
	git submodule update --force --remote $(PROTO_ROOT)
	
##### Docker #####
docker-server:
	@printf $(COLOR) "Building docker image temporalio/server:$(DOCKER_IMAGE_TAG)..."
	docker build . -f server.Dockerfile -t temporalio/server:$(DOCKER_IMAGE_TAG)

docker-auto-setup:
	@printf $(COLOR) "Build docker image temporalio/auto-setup:$(DOCKER_IMAGE_TAG)..."
	docker build . -f auto-setup.Dockerfile -t temporalio/auto-setup:$(DOCKER_IMAGE_TAG)

docker-admin-tools:
	@printf $(COLOR) "Build docker image temporalio/admin-tools:$(DOCKER_IMAGE_TAG)..."
	docker build . -f admin-tools.Dockerfile -t temporalio/admin-tools:$(DOCKER_IMAGE_TAG)
