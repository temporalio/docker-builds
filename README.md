> [!WARNING]
> This repository is deprecated and no longer actively maintained.
> - `temporalio/admin-tools` and `temporalio/server` image builds have been moved to [temporalio/server](https://github.com/temporalio/server)
> - `temporalio/auto-setup`, `temporalio/base-server`, `temporalio/base-builder`, `temporalio/base-ci-builder`, and `temporalio/base-admin-tools` images are deprecated.

# docker-builds
[![Update Submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)
[![Build Docker Images](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml)

A set of workflows that publish:

- https://hub.docker.com/repository/docker/temporaliotest/auto-setup
- https://hub.docker.com/repository/docker/temporaliotest/server
- https://hub.docker.com/repository/docker/temporaliotest/admin-tools

## Hardened lineage

This repo now builds runtime images from hardened Wolfi-based internal base targets:

- `docker/base-images/base-runtime-hardened.Dockerfile` for `server` and `auto-setup`.
- `docker/base-images/base-admin-tools-hardened.Dockerfile` for `admin-tools` (including `cqlsh` support).

Final image Dockerfiles consume those internal targets via `docker-bake.hcl` contexts.

## AWS feature flags

AWS integrations are controlled via `TEMPORAL_BUILD_TAG`:

- This repo now defaults to `TEMPORAL_BUILD_TAG=aws`, so S3 archival support is compiled into server binaries.
- To build hardened `!aws` binaries (S3 disabled and ES AWS signing disabled), run:
  - `make TEMPORAL_BUILD_TAG= build-native`
- `docker-compose.yml` is now Postgres-only (no Elasticsearch) and includes S3 history archival env vars:
  - `ENABLE_S3_ARCHIVAL`
  - `S3_ARCHIVAL_BUCKET`
  - `S3_ARCHIVAL_REGION`
  - `S3_ARCHIVAL_ENDPOINT` (optional, for MinIO/LocalStack/custom endpoint)
  - `S3_ARCHIVAL_FORCE_PATH_STYLE`
- GCS (`gs://`) archival is intentionally not supported by this hardened runtime path.

The `aws` build now uses `github.com/aws/aws-sdk-go-v2` only.

## Module overrides

To keep the workspace on a no-v1 module graph:

- `cli/go.mod` and `tctl/go.mod` currently use `replace go.temporal.io/server => ../temporal`.
- `temporal/go.mod`, `cli/go.mod`, and `tctl/go.mod` use `replace github.com/olivere/elastic/v7 => ../third_party/elastic-v7` (local fork with no `github.com/aws/aws-sdk-go` v1 requirement).

For remote CI/release builds, pin `go.temporal.io/server` to your published fork commit (`github.com/Apurer/temporal`) instead of the local path replace.

## Security scans

Use local deterministic scan targets after `make build-native`:

```bash
make scan-grype
make scan-trivy
make scan-scout
make scan-all
make scan-all-with-scout
```

Scan outputs are written to `scan-results/` as JSON and SARIF.
CI also uploads scanner metadata (scanner versions and Trivy DB metadata) under `scan-results/meta/`.
Docker Scout requires Docker authentication (`docker login`) before running `make scan-scout`.


## Workflows

There are 3 distinct phases:

### (1) Docker base images

All build steps require a set of Docker base images.
They are released by a user whenever a new version of a base image is needed.

* [release-base-image](https://github.com/temporalio/docker-builds/actions/workflows/release-base-image.yml):
  build and release a **single** Docker base image (`temporalio/base-*`) to DockerHub [temporalio](https://hub.docker.com/u/temporalio)
* [release-all-base-image](https://github.com/temporalio/docker-builds/actions/workflows/release-all-base-image.yml):
  build and release **all** Docker base images (`temporalio/base-*`) to DockerHub [temporalio](https://hub.docker.com/u/temporalio)

Read [more details about base images](./docker/base-images/README.md).

### (2) Docker pre-release images

For every commit to Temporal Server's main and release branches,
its [Trigger Publish](https://github.com/temporalio/temporal/blob/main/.github/workflows/trigger-publish.yml)
will invoke [update-submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)
to update all submodules to their latest commit - and run the following actions:

* [lint](https://github.com/temporalio/docker-builds/actions/workflows/lint.yml):
  lint repo's shell scripts
* [docker](https://github.com/temporalio/docker-builds/actions/workflows/docker.yml):
  build Docker images and publish to DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest)
* [docker-build-only](https://github.com/temporalio/docker-builds/actions/workflows/docker-build-only.yml):
  build Docker images, but don't publish (used by `features-integration` workflow)
* [features-integration](https://github.com/temporalio/docker-builds/actions/workflows/features-integration.yml):
  run integration tests against [features repo](https://github.com/temporalio/features)

### (3) Docker release images

Users can publish any of the previously built images via:

* [release-admin-tools](https://github.com/temporalio/docker-builds/actions/workflows/release-admin-tools.yml):
  copy `admin-tools` image from DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest) to
  DockerHub [temporalio](https://hub.docker.com/u/temporalio)
* [release-temporal](https://github.com/temporalio/docker-builds/actions/workflows/release-temporal.yml):
  copy `server` and `auto-setup` images from DockerHub [temporaliotest](https://hub.docker.com/u/temporaliotest) to
  DockerHub [temporalio](https://hub.docker.com/u/temporalio)


## Manually build Docker image for any commit

Replace **YOUR_TAG** and **YOUR_CHECKOUT_COMMIT** to build manually:

```bash
git checkout YOUR_CHECKOUT_COMMIT
docker build . -f server.Dockerfile -t temporalio/auto-setup:YOUR_TAG
```
