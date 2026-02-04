ARG BASE_ADMIN_TOOLS_IMAGE=temporalio/base-admin-tools:1.12.16

##### Admin Tools #####
# This is injected as a context via the bakefile so we don't take it as an ARG
FROM temporaliotest/server as server

##### Temporal admin tools #####
FROM ${BASE_ADMIN_TOOLS_IMAGE} as temporal-admin-tools
ARG TARGETARCH

COPY ./build/${TARGETARCH}/tctl /usr/local/bin
COPY ./build/${TARGETARCH}/tctl-authorization-plugin /usr/local/bin
COPY ./build/${TARGETARCH}/temporal /usr/local/bin
COPY ./build/${TARGETARCH}/temporal-cassandra-tool /usr/local/bin
COPY ./build/${TARGETARCH}/temporal-sql-tool /usr/local/bin
COPY ./build/${TARGETARCH}/tdbg /usr/local/bin
COPY ./temporal/schema /etc/temporal/schema

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
