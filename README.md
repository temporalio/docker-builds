# docker-builds
[![Update Submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)
[![Build Docker Images](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml)

A set of workflows that publish:

- https://hub.docker.com/repository/docker/temporaliotest/auto-setup
- https://hub.docker.com/repository/docker/temporaliotest/server
- https://hub.docker.com/repository/docker/temporaliotest/admin-tools


## Workflows

There are 3 distinct phases:

### (1) Docker base images

All build steps require a set of Docker base images.
They are released by a user whenever a new version of a base image is needed.

* [release-base-image](./actions/workflows/release-base-image.yml):
  build and release a **single** Docker base image (`temporalio/base-*`) to DockerHub [temporalio](https://hub.docker.com/u/temporalio)
* [release-all-base-image](./actions/workflows/release-all-base-image.yml):
  build and release **all** Docker base images (`temporalio/base-*`) to DockerHub [temporalio](https://hub.docker.com/u/temporalio)

Read [more details about base images](./docker/base-images/README.md).

### (2) Docker pre-release images

For every commit to Temporal Server's main and release branch,
its [Trigger Publish](https://github.com/temporalio/temporal/blob/main/.github/workflows/trigger-publish.yml)
will invoke [update-submodules](./actions/workflows/update-submodules.yml)
to update all submodules to their latest commit - and run the following actions:

* [lint](./actions/workflows/lint.yml):
  lint repo's shell scripts
* [docker](./actions/workflows/docker.yml):
  build Docker images and publish to DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest)
* [docker-build-only](./actions/workflows/docker-build-only.yml):
  build Docker images, but don't publish (used by `features-integration` workflow)
* [features-integration](./actions/workflows/features-integration.yml):
  run integration tests against [features repo](https://github.com/temporalio/features)

### (3) Docker release images

Users can publish any of the previously built images via:

* [release-admin-tools](./actions/workflows/release-admin-tools.yml):
  copy `admin-tools` image from DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest) to
  DockerHub [temporalio](https://hub.docker.com/u/temporalio)
* [release-temporal](./actions/workflows/release-temporal.yml):
  copy `server` and `auto-setup` images from DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest) to
  DockerHub [temporalio](https://hub.docker.com/u/temporalio)


## Manually build Docker image for any commit

Replace **YOUR_TAG** and **YOUR_CHECKOUT_COMMIT** to build manually:

```bash
git checkout YOUR_CHECKOUT_COMMIT
docker build . -f auto-setup.Dockerfile -t temporalio/auto-setup:YOUR_TAG
```
