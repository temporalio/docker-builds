[![Publish Admin Tools image](https://github.com/temporalio/docker-builds/actions/workflows/docker-admin-tools.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker-admin-tools.yml)
[![Publish Temporal server image](https://github.com/temporalio/docker-builds/actions/workflows/docker-server.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker-server.yml)
[![Publish Temporal server with auto-setup image](https://github.com/temporalio/docker-builds/actions/workflows/docker-auto-setup.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/docker-auto-setup.yml)

[![Update Submodules](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml/badge.svg)](https://github.com/temporalio/docker-builds/actions/workflows/update-submodules.yml)

# Build docker image

Temporal builds 3 Docker images with [every release](https://github.com/temporalio/temporal/releases): Server, Server [with Auto Setup](https://docs.temporal.io/blog/auto-setup), and Admin-Tools. Docker images are built via [Github Actions docker-builds](https://github.com/temporalio/docker-builds/actions) There are [other builds e.g. for CI](https://hub.docker.com/u/temporalio) as well.

## Prerequisites

To build docker image:
  * [docker](https://docs.docker.com/engine/installation/)

To run docker image with dependencies:
  * [docker-compose](https://docs.docker.com/compose/install/)

## Build docker image for any commit

Refer to [docker-builds](https://github.com/temporalio/docker-builds) to build the images manually.

## Run Temporal with custom docker image

Clone Temporal docker-compose repo: [https://github.com/temporalio/docker-compose](https://github.com/temporalio/docker-compose):
```bash
git clone https://github.com/temporalio/docker-compose.git
```

Replace the tag of `image: temporalio/auto-setup` to **YOUR_TAG** in `docker-compose.yml`.
Then start the service using the below command:
```bash
docker-compose up
```

## Quickstart for production

In a typical production setting, dependencies (such as `cassandra` or `elasticsearch`) are managed/started independently of the Temporal server.
To use the container in a production setting, use the following command:

```plain
docker run -e CASSANDRA_SEEDS=10.x.x.x                  -- csv of cassandra server ipaddrs
    -e KEYSPACE=<keyspace>                              -- Cassandra keyspace
    -e VISIBILITY_KEYSPACE=<visibility_keyspace>        -- Cassandra visibility keyspace
    -e SKIP_SCHEMA_SETUP=true                           -- do not setup cassandra schema during startup
    -e NUM_HISTORY_SHARDS=1024  \                       -- Number of history shards
    -e SERVICES=history,matching \                      -- Spinup only the provided services
    -e LOG_LEVEL=debug,info \                           -- Logging level
    -e DYNAMIC_CONFIG_FILE_PATH=config/foo.yaml         -- Dynamic config file to be watched
    temporalio/server:<tag>
```
