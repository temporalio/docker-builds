##### dockerize builder: built from source to support arm & x86 #####
FROM golang:1.20-alpine3.17 AS dockerize-builder

RUN apk add --update --no-cache \
    git

RUN mkdir -p /xsrc && \
    git clone https://github.com/jwilder/dockerize.git && \
    cd dockerize && \
    go build -o /usr/local/bin/dockerize . && \
    rm -rf /xsrc

##### base-server target #####
FROM alpine:3.17 AS base-server

# todo: remove libcrypto3 and libssl3 when alpine 3.18 is released
RUN apk add --update --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    libcrypto3 \
    libssl3

COPY --from=dockerize-builder /usr/local/bin/dockerize /usr/local/bin/dockerize

SHELL ["/bin/bash", "-c"]
