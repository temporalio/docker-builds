ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.11.0
ARG BASE_ADMIN_TOOLS_IMAGE=temporalio/base-admin-tools:1.9.0
ARG SERVER_IMAGE
ARG GOPROXY

##### Temporal Admin Tools builder #####
FROM ${BASE_BUILDER_IMAGE} AS admin-tools-builder
ARG TEMPORAL_REPO_PATH=temporal
ARG GOFLAGS
ENV GOFLAGS ${GOFLAGS}

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./${TEMPORAL_REPO_PATH}/go.mod ./${TEMPORAL_REPO_PATH}/go.sum ./temporal/
RUN (cd ./temporal && go mod download all)

# build
COPY ./${TEMPORAL_REPO_PATH} ./temporal
RUN (cd ./temporal && make temporal-cassandra-tool temporal-sql-tool tdbg)


##### Server #####
FROM ${SERVER_IMAGE} as server


##### Temporal admin tools #####
FROM ${BASE_ADMIN_TOOLS_IMAGE} as temporal-admin-tools

WORKDIR /etc/temporal

COPY --from=server /usr/local/bin/tctl /usr/local/bin
COPY --from=server /usr/local/bin/tctl-authorization-plugin /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-cassandra-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-sql-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/schema /etc/temporal/schema
COPY --from=admin-tools-builder /home/builder/temporal/tdbg /usr/local/bin

# Keep the container running.
ENTRYPOINT ["tail", "-f", "/dev/null"]
