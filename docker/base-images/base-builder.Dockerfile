FROM golang:1.18.0-alpine3.15 AS base-builder

RUN apk add --update --no-cache \
    make \
    git
