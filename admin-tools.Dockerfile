ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.14.1
ARG BASE_ADMIN_TOOLS_IMAGE=temporalio/base-admin-tools:1.12.1
ARG SERVER_IMAGE
ARG GOPROXY

##### Temporal Admin Tools builder #####
FROM ${BASE_BUILDER_IMAGE} AS admin-tools-builder

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./temporal/go.mod ./temporal/go.sum ./temporal/
RUN (cd ./temporal && go mod download all)

# build
COPY ./temporal ./temporal
# Git info is needed for Go build to attach VCS information properly.
# See the `buildvcs` Go flag: https://pkg.go.dev/cmd/go
COPY ./.git ./.git
COPY ./.gitmodules ./.gitmodules
RUN (cd ./temporal && make temporal-cassandra-tool temporal-sql-tool tdbg)


##### Server #####
FROM ${SERVER_IMAGE} as server


##### Temporal admin tools #####
FROM ${BASE_ADMIN_TOOLS_IMAGE} as temporal-admin-tools

COPY --from=server /usr/local/bin/tctl /usr/local/bin
COPY --from=server /usr/local/bin/tctl-authorization-plugin /usr/local/bin
COPY --from=server /usr/local/bin/temporal /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-cassandra-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/temporal-sql-tool /usr/local/bin
COPY --from=admin-tools-builder /home/builder/temporal/schema /etc/temporal/schema
COPY --from=admin-tools-builder /home/builder/temporal/tdbg /usr/local/bin

# Alpine has a /etc/bash/bashrc that sources all files named /etc/bash/*.sh for
# interactive shells, so we can add completion logic in /etc/bash/temporal-completion.sh
# Completion for temporal depends on the bash-completion package.
RUN apk add bash-completion && \
    temporal completion bash > /etc/bash/temporal-completion.sh && \
    addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal
USER temporal
WORKDIR /etc/temporal

# Keep the container running.
ENTRYPOINT ["tini", "--", "sleep", "infinity"]
