FROM golang:1.22-alpine3.20 AS base-builder

RUN apk add --update --no-cache \
    make \
    git \
    curl
