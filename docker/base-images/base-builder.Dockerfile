FROM golang:1.21-alpine3.18 AS base-builder

RUN apk add --update --no-cache \
    make \
    git \
    curl
