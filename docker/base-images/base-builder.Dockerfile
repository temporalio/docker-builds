FROM golang:1.19-alpine3.17 AS base-builder

RUN apk add --update --no-cache \
    make \
    git
