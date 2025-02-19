FROM golang:1.23.4-alpine3.21 AS base-builder

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    make \
    git \
    curl
