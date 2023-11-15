ARG GOPROXY

##### Admin Tools #####
FROM admin-tools

##### Temporal server with Auto-Setup #####
FROM server
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

CMD ["autosetup"]

ENTRYPOINT ["/etc/temporal/entrypoint.sh"]
