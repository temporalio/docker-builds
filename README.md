[![Update Submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)
[![Build Docker Images](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml)

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
