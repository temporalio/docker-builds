ARG BASE_BUILDER_IMAGE=temporalio/base-builder:1.4.0
ARG BASE_SERVER_IMAGE=temporalio/base-server:1.4.0
ARG GOPROXY

##### Temporal Admin Tools builder #####
FROM ${BASE_BUILDER_IMAGE} AS temporal-builder

WORKDIR /home/builder

# cache Temporal packages as a docker layer
COPY ./temporal/go.mod ./temporal/go.sum ./temporal/
RUN (cd ./temporal && go mod download)

# cache tctl packages as a docker layer
COPY ./tctl/go.mod ./tctl/go.sum ./tctl/
RUN (cd ./tctl && go mod download)

# build
COPY . .
RUN (cd ./temporal && make bins)
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

COPY --from=temporal-builder /home/builder/tctl/tctl /usr/local/bin
COPY --from=temporal-builder /home/builder/tctl/tctl-authorization-plugin /usr/local/bin
COPY --from=temporal-builder /home/builder/temporal/temporal-server /usr/local/bin

COPY temporal/config/dynamicconfig /etc/temporal/config/dynamicconfig
COPY temporal/docker/config_template.yaml /etc/temporal/config/config_template.yaml
COPY temporal/docker/entrypoint.sh /etc/temporal/entrypoint.sh
COPY temporal/docker/start-temporal.sh /etc/temporal/start-temporal.sh

USER temporal
ENTRYPOINT ["/etc/temporal/entrypoint.sh"]

##### Auto setup Temporal server #####
FROM temporal-server AS temporal-auto-setup
CMD ["autosetup"]

COPY --from=temporal-builder /home/builder/temporal/schema /etc/temporal/schema
COPY --from=temporal-builder /home/builder/temporal/temporal-cassandra-tool /usr/local/bin
COPY --from=temporal-builder /home/builder/temporal/temporal-sql-tool /usr/local/bin

COPY temporal/docker/auto-setup.sh /etc/temporal/auto-setup.sh

##### Development configuration for Temporal with additional set of tools #####
FROM temporal-auto-setup as temporal-develop

# apk and setup-develop.sh requires root permissions.
USER root
# iproute2 contains tc, which can be used for traffic shaping in resiliancy testing. 
ONBUILD RUN apk add iproute2

CMD ["autosetup", "develop"]

COPY temporal/docker/setup-develop.sh /etc/temporal/setup-develop.sh
