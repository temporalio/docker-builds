ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.4.0
ARG BASE_ADMIN_TOOLS_IMAGE=temporalio/base-admin-tools:1.2.0
ARG GOPROXY

##### Temporal Admin Tools builder #####
FROM ${BASE_BUILDER_IMAGE} AS admin-tools-builder

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./temporal/go.mod ./temporal/go.sum ./temporal/
RUN (cd ./temporal && go mod download)

# cache tctl packages as a docker layer
COPY ./tctl/go.mod ./tctl/go.sum ./tctl/
RUN (cd ./tctl && go mod download)

COPY ./temporal ./temporal
RUN (cd ./temporal && make bins)

COPY ./tctl ./tctl
RUN (cd ./tctl && make build)

##### Temporal admin tools #####
FROM ${BASE_ADMIN_TOOLS_IMAGE} as temporal-admin-tools
WORKDIR /etc/temporal

COPY --from=admin-tools-builder /home/builder/temporal/schema /etc/temporal/schema
COPY --from=admin-tools-builder /home/builder/temporal/temporal-cassandra-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-sql-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/tctl/tctl /usr/local/bin
COPY --from=admin-tools-builder /home/builder/tctl/tctl-authorization-plugin /usr/local/bin

# Keep the container running.
ENTRYPOINT ["tail", "-f", "/dev/null"]
