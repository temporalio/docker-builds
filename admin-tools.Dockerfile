ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.12.0
ARG BASE_ADMIN_TOOLS_IMAGE=temporalio/base-admin-tools:1.10.0
ARG SERVER_IMAGE
ARG GOPROXY

##### Temporal Admin Tools builder #####
FROM ${BASE_BUILDER_IMAGE} AS admin-tools-builder

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./temporal/go.mod ./temporal/go.sum ./temporal/
RUN (cd ./temporal && go mod download all)

# cache Temporal CLI packages as a docker layer
COPY ./cli/go.mod ./cli/go.sum ./cli/
RUN (cd ./cli && go mod download all)

# build
COPY ./temporal ./temporal
# Git info is needed for Go build to attach VCS information properly.
# See the `buildvcs` Go flag: https://pkg.go.dev/cmd/go
COPY ./.git ./.git
COPY ./.gitmodules ./.gitmodules
RUN (cd ./temporal && make temporal-cassandra-tool temporal-sql-tool tdbg)

COPY ./cli ./cli
RUN (cd ./cli && make build)


##### Server #####
FROM ${SERVER_IMAGE} as server


##### Temporal admin tools #####
FROM ${BASE_ADMIN_TOOLS_IMAGE} as temporal-admin-tools

WORKDIR /etc/temporal

RUN addgroup -g 1000 temporal
RUN adduser -u 1000 -G temporal -D temporal
USER temporal

COPY --from=server /usr/local/bin/tctl /usr/local/bin
COPY --from=server /usr/local/bin/tctl-authorization-plugin /usr/local/bin
COPY --from=server /usr/local/bin/temporal /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-cassandra-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-sql-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/schema /etc/temporal/schema
COPY --from=admin-tools-builder /home/builder/temporal/tdbg /usr/local/bin

# Keep the container running.
ENTRYPOINT ["tail", "-f", "/dev/null"]
