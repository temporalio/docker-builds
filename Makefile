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
