FROM golang:1.20-alpine3.17 AS base-builder

RUN apk add --update --no-cache \
    make \
    git \
    curl
