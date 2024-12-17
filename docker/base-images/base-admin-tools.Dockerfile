ARG BASE_IMAGE=alpine:3.21

FROM ${BASE_IMAGE} AS builder

# Alpine v3.20 comes with Python 3.12. But cqlsh won't work with Python 3.12 until the following issue is resolved.
# https://issues.apache.org/jira/browse/CASSANDRA-19206
# Compiling Python 3.11.9 from source and installing it on the side. Then creating a venv using that python version.
# Revert this change once the issue mentioned above is resolved.
RUN apk add --update --no-cache \
    musl-dev \
    libffi-dev \
    gcc \
    make \
    zlib-dev \
    openssl-dev

RUN mkdir -p /opt/python/3.11.9 ; \
    cd /opt/python/3.11.9/ ; \
    wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz -P . ; \
    tar zxvf Python-3.11.9.tgz ; \
    cd Python-3.11.9 ; \
    ./configure --prefix=/opt/python/3.11.9; \
    make ; \
    make install ; \
    make clean ; \
    cd .. ; \
    rm -rf Python-3.11.9*

RUN cd /opt/python/3.11.9/bin ; ./python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install cqlsh

FROM ${BASE_IMAGE} AS base-admin-tools

RUN apk add --update --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    jq \
    yq \
    mysql-client \
    postgresql-client \
    py3-pip \
    expat \
    tini

COPY --from=builder /opt/python/3.11.9 /opt/python/3.11.9
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# validate installation
RUN cqlsh --version

SHELL ["/bin/bash", "-c"]
