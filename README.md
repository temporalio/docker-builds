[![Publish Admin Tools image](https://github.com/temporalio/docker-builds/actions/workflows/docker-admin-tools.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker-admin-tools.yml)
[![Publish Temporal server image](https://github.com/temporalio/docker-builds/actions/workflows/docker-server.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker-server.yml)
[![Publish Temporal server with auto-setup image](https://github.com/temporalio/docker-builds/actions/workflows/docker-auto-setup.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker-auto-setup.yml)

[![Update Submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)

# Docker images build and publish

A set of pipelines that build:

- https://hub.docker.com/repository/docker/temporaliotest/auto-setup
- https://hub.docker.com/repository/docker/temporaliotest/server
- https://hub.docker.com/repository/docker/temporaliotest/admin-tools

## Build docker image for any commit

Replace **YOUR_TAG** and **YOUR_CHECKOUT_COMMIT** to build manually:

```bash
git checkout YOUR_CHECKOUT_COMMIT
docker build . -f auto-setup.Dockerfile -t temporalio/auto-setup:YOUR_TAG
```
