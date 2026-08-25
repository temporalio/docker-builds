ARG BASE_ADMIN_TOOLS_IMAGE=temporalio/base-admin-tools:1.12.15

# This is injected as a context via the bakefile so we don't take it as an ARG.
# Not a registry pull (bake replaces it with the "server" build target), so it
# can't be tag-pinned like a normal FROM.
# Also a known false positive for trivy's DS-0001 check, which this comment can't
# simultaneously suppress alongside the hadolint ignore below (each tool only honors
# its own directive when it's the comment immediately adjacent to the instruction).
# hadolint ignore=DL3006
FROM temporaliotest/server AS server

FROM ${BASE_ADMIN_TOOLS_IMAGE} AS temporal-admin-tools
ARG TARGETARCH

# Copy admin tool binaries
COPY ./build/${TARGETARCH}/tctl /usr/local/bin/
COPY ./build/${TARGETARCH}/tctl-authorization-plugin /usr/local/bin/
COPY ./build/${TARGETARCH}/temporal /usr/local/bin/
COPY ./build/${TARGETARCH}/temporal-cassandra-tool /usr/local/bin/
COPY ./build/${TARGETARCH}/temporal-sql-tool /usr/local/bin/
COPY ./build/${TARGETARCH}/tdbg /usr/local/bin/

# Copy schema files
COPY ./temporal/schema /etc/temporal/schema

# Alpine has a /etc/bash/bashrc that sources all files named /etc/bash/*.sh for
# interactive shells, so we can add completion logic in /etc/bash/temporal-completion.sh
# Completion for temporal depends on the bash-completion package.
RUN apk add --no-cache bash-completion=2.17.0-r1 && \
    temporal completion bash > /etc/bash/temporal-completion.sh && \
    addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal

USER temporal
WORKDIR /etc/temporal

# Keep the container running.
ENTRYPOINT ["tini", "--", "sleep", "infinity"]
