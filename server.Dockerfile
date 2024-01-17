ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.14.7
ARG BASE_SERVER_IMAGE=temporalio/base-server:1.15.6

##### Builder #####
FROM ${BASE_BUILDER_IMAGE} AS temporal-builder
ARG TEMPORAL_CLI_VERSION=latest

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./temporal/go.mod ./temporal/go.sum ./temporal/
RUN --mount=type=cache,target=/root/.cache/go-build (cd ./temporal && go mod download all)

# cache tctl packages as a docker layer
COPY ./tctl/go.mod ./tctl/go.sum ./tctl/
RUN --mount=type=cache,target=/root/.cache/go-build (cd ./tctl && go mod download all)

# install Temporal CLI
RUN sh -c "$(curl -sSf https://temporal.download/cli.sh)" -- --dir ./cli --version "$TEMPORAL_CLI_VERSION" && \
    mv ./cli/bin/temporal ./cli/ && chown 0:0 ./cli/temporal

# build
COPY ./tctl ./tctl
COPY ./temporal ./temporal
# Git info is needed for Go build to attach VCS information properly.
# See the `buildvcs` Go flag: https://pkg.go.dev/cmd/go
COPY ./.git ./.git
COPY ./.gitmodules ./.gitmodules
RUN --mount=type=cache,target=/root/.cache/go-build (cd ./temporal && make temporal-server)
RUN --mount=type=cache,target=/root/.cache/go-build (cd ./tctl && make build)

##### Temporal server #####
FROM ${BASE_SERVER_IMAGE} as temporal-server
ARG TEMPORAL_SHA=unknown
ARG TCTL_SHA=unknown

WORKDIR /etc/temporal

ENV TEMPORAL_HOME=/etc/temporal
EXPOSE 6933 6934 6935 6939 7233 7234 7235 7239

# TODO switch WORKDIR to /home/temporal and remove "mkdir" and "chown" calls.
RUN addgroup -g 1000 temporal
RUN adduser -u 1000 -G temporal -D temporal
RUN mkdir /etc/temporal/config
RUN chown -R temporal:temporal /etc/temporal/config
USER temporal

# store component versions in the environment
ENV TEMPORAL_SHA=${TEMPORAL_SHA}
ENV TCTL_SHA=${TCTL_SHA}

# binaries
COPY --from=temporal-builder /home/builder/tctl/tctl /usr/local/bin
COPY --from=temporal-builder /home/builder/tctl/tctl-authorization-plugin /usr/local/bin
COPY --from=temporal-builder /home/builder/temporal/temporal-server /usr/local/bin
COPY --from=temporal-builder /home/builder/cli/temporal /usr/local/bin

# configs
COPY ./temporal/config/dynamicconfig/docker.yaml /etc/temporal/config/dynamicconfig/docker.yaml
COPY ./temporal/docker/config_template.yaml /etc/temporal/config/config_template.yaml

# scripts
COPY ./docker/entrypoint.sh /etc/temporal/entrypoint.sh
COPY ./docker/start-temporal.sh /etc/temporal/start-temporal.sh

### Server release image ###
FROM temporal-server as server
ENTRYPOINT ["/etc/temporal/entrypoint.sh"]

### Server auto-setup image ###
##### Admin Tools #####
# This is injected as a context via the bakefile so we don't take it as an ARG
FROM temporaliotest/admin-tools as admin-tools
FROM temporal-server as auto-setup

WORKDIR /etc/temporal

# binaries
COPY --from=admin-tools /usr/local/bin/temporal-cassandra-tool /usr/local/bin
COPY --from=admin-tools /usr/local/bin/temporal-sql-tool /usr/local/bin

# configs
COPY --from=admin-tools /etc/temporal/schema /etc/temporal/schema

# scripts
COPY ./docker/entrypoint.sh /etc/temporal/entrypoint.sh
COPY ./docker/start-temporal.sh /etc/temporal/start-temporal.sh
COPY ./docker/auto-setup.sh /etc/temporal/auto-setup.sh

ENTRYPOINT ["/etc/temporal/entrypoint.sh"]
CMD ["autosetup"]
