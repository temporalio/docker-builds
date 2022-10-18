##### dockerize builder: built from source to support arm & x86 #####
FROM golang:1.19-alpine3.16 AS dockerize-builder

RUN apk add --update --no-cache \
    git

RUN mkdir -p /xsrc && \
    git clone https://github.com/jwilder/dockerize.git && \
    cd dockerize && \
    go build -o /usr/local/bin/dockerize . && \
    rm -rf /xsrc

##### base-server target #####
FROM alpine:3.16 AS base-server

RUN apk add --update --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl

COPY --from=dockerize-builder /usr/local/bin/dockerize /usr/local/bin/dockerize
# set up nsswitch.conf for Go's "netgo" implementation
# https://github.com/gliderlabs/docker-alpine/issues/367#issuecomment-424546457
RUN test ! -e /etc/nsswitch.conf && echo 'hosts: files dns' > /etc/nsswitch.conf

SHELL ["/bin/bash", "-c"]
