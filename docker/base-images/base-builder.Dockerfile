FROM golang:1.18-alpine3.16 AS base-builder

RUN apk add --update --no-cache \
    make \
    git
