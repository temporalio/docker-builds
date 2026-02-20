ARG BASE_ADMIN_TOOLS_IMAGE=base-admin-tools-hardened

# This is injected as a context via the bakefile so we don't take it as an ARG
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
RUN apk add --no-cache bash-completion && \
    mkdir -p /etc/bash && \
    temporal completion bash > /etc/bash/temporal-completion.sh && \
    addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal

USER temporal
WORKDIR /etc/temporal

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD /bin/bash -ec 'addr="${TEMPORAL_ADDRESS:-${TEMPORAL_CLI_ADDRESS:-}}"; if [[ -n "${addr}" ]]; then out="$(temporal operator cluster health --address "${addr}" 2>/dev/null)"; [[ "${out}" == *"SERVING"* ]]; else temporal --version >/dev/null && tctl --version >/dev/null; fi'

# Keep the container running.
ENTRYPOINT ["tini", "--", "sleep", "infinity"]
