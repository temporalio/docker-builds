FROM registry.access.redhat.com/ubi9/ubi-minimal AS fetcher

ARG TEMPORAL_VERSION=1.27.2
ARG DOCKERIZE_VERSION=v0.9.2

RUN microdnf install -y wget tar gzip ca-certificates && microdnf clean all

RUN wget -qO- https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    | tar -xz -C /usr/local/bin

RUN cd /tmp && \
    wget https://github.com/temporalio/temporal/releases/download/v${TEMPORAL_VERSION}/temporal_${TEMPORAL_VERSION}_linux_amd64.tar.gz && \
    tar -xzf temporal_${TEMPORAL_VERSION}_linux_amd64.tar.gz -C /tmp/ && \
    mv /tmp/temporal-server /usr/local/bin/temporal-server

#  Download source tarball and extract schema
RUN curl -fsSL https://github.com/temporalio/temporal/archive/refs/tags/v${TEMPORAL_VERSION}.tar.gz \
    | tar -xz --strip-components=1 -C /tmp \
        temporal-${TEMPORAL_VERSION}/schema \
        temporal-${TEMPORAL_VERSION}/config \
        temporal-${TEMPORAL_VERSION}/docker/config_template.yaml && \
    mkdir -p /etc/temporal/schema /etc/temporal/config && \
    mv /tmp/schema /etc/temporal/schema && \
    mv /tmp/config/* /etc/temporal/config/ && \
    mv /tmp/docker/config_template.yaml /etc/temporal/config/


FROM registry.access.redhat.com/ubi9/ubi-minimal AS base-server

RUN microdnf install -y tzdata ca-certificates bash gettext hostname && microdnf clean all

COPY --from=fetcher /usr/local/bin/dockerize /usr/local/bin/
COPY --from=fetcher /usr/local/bin/temporal-server /usr/local/bin/
COPY --from=fetcher /etc/temporal/config /etc/temporal/config
COPY --from=fetcher /etc/temporal/schema /etc/temporal/schema

COPY docker/entrypoint.sh docker/start-temporal.sh docker/auto-setup.sh /etc/temporal/
RUN chmod +x /etc/temporal/*.sh

WORKDIR /etc/temporal
EXPOSE 7233 8233 9233
ENTRYPOINT ["/etc/temporal/entrypoint.sh"]
