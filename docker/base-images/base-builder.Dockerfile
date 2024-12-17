FROM golang:1.23.2-alpine3.21 AS base-builder

RUN apk add --update --no-cache \
    make \
    git \
    curl
