ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.7.0
ARG BASE_SERVER_IMAGE=temporalio/base-server:1.7.0
ARG GOPROXY

##### Builder #####
FROM ${BASE_BUILDER_IMAGE} AS temporal-builder

ARG GITHUB_SHA_SHORT

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./temporal/go.mod ./temporal/go.sum ./temporal/
RUN (cd ./temporal && go mod download all)

# cache tctl packages as a docker layer
COPY ./tctl/go.mod ./tctl/go.sum ./tctl/
RUN (cd ./tctl && go mod download all)

# build
COPY . .
RUN (cd ./temporal && CGO_ENABLED=0 make temporal-server)
RUN (cd ./tctl && make build)

##### Temporal server #####
FROM ${BASE_SERVER_IMAGE} as temporal-server
WORKDIR /etc/temporal

ENV TEMPORAL_HOME /etc/temporal
ENV SERVICES "history:matching:frontend:worker"
EXPOSE 6933 6934 6935 6939 7233 7234 7235 7239

# TODO switch WORKDIR to /home/temporal and remove "mkdir" and "chown" calls.
RUN addgroup -g 1000 temporal
RUN adduser -u 1000 -G temporal -D temporal
RUN mkdir /etc/temporal/config
RUN chown -R temporal:temporal /etc/temporal/config
USER temporal

# binaries
COPY --from=temporal-builder /home/builder/tctl/tctl /usr/local/bin
COPY --from=temporal-builder /home/builder/tctl/tctl-authorization-plugin /usr/local/bin
COPY --from=temporal-builder /home/builder/temporal/temporal-server /usr/local/bin

# configs
COPY temporal/config/dynamicconfig /etc/temporal/config/dynamicconfig
COPY temporal/docker/config_template.yaml /etc/temporal/config/config_template.yaml

# scripts
COPY ./docker/entrypoint.sh /etc/temporal/entrypoint.sh
COPY ./docker/start-temporal.sh /etc/temporal/start-temporal.sh

ENTRYPOINT ["/etc/temporal/entrypoint.sh"]
