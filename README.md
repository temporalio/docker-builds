# docker-builds
[![Update Submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)
[![Build Docker Images](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml)

A set of workflows that publish:

- https://hub.docker.com/repository/docker/temporaliotest/auto-setup
- https://hub.docker.com/repository/docker/temporaliotest/server
- https://hub.docker.com/repository/docker/temporaliotest/admin-tools


## Workflows

Docker images are built and published to DockerHub's [temporaliotest](https://hub.docker.com/u/temporaliotest)
for every commit to [Temporal Server](https://github.com/temporalio/temporal)'s main
branch and release branches (triggered by `update-submodules`, see below).

Users can then release any of these images to DockerHub's [temporalio](https://hub.docker.com/u/temporalio).

### On push:

* [lint](./actions/workflows/lint.yml):
  lint repo's shell scripts
* [docker](./actions/workflows/docker.yml): 
  build Docker images and publish to DockerHub's [temporaliotest](https://hub.docker.com/u/temporaliotest)
* [features-integration](./actions/workflows/features-integration.yml):
  run integration tests against [features repo](https://github.com/temporalio/features)

### On demand by automation:

* [update-submodules](./actions/workflows/update-submodules.yml):
  updates submodules to latest commit (invoked by `temporal-cicd` bot)

### On demand by user:

* [docker-build-only](./actions/workflows/docker-build-only.yml):
  build Docker images, but don't publish (re-used by `features-integration` workflow)
* [release-admin-tools](./actions/workflows/release-admin-tools.yml):
  copy `admin-tools` image from DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest) to
  DockerHub's [temporalio](https://hub.docker.com/u/temporalio)
* [release-temporal](./actions/workflows/release-temporal.yml):
  copy `server` and `auto-setup` images from DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest) to
  DockerHub's [temporalio](https://hub.docker.com/u/temporalio)


* [release-base-image](./actions/workflows/release-base-image.yml):
  build and release Docker a **single** base image (`temporalio/base-*`) to DockerHub's [temporalio](https://hub.docker.com/u/temporalio)
* [release-all-base-image](./actions/workflows/release-all-base-image.yml):
  build and release **all** Docker base images (`temporalio/base-*`) to DockerHub's [temporalio](https://hub.docker.com/u/temporalio)


Read [more details about base images](./docker/base-images/README.md).

## Manually build Docker image for any commit

Replace **YOUR_TAG** and **YOUR_CHECKOUT_COMMIT** to build manually:

```bash
git checkout YOUR_CHECKOUT_COMMIT
docker build . -f auto-setup.Dockerfile -t temporalio/auto-setup:YOUR_TAG
```
