FROM golang:1.17.6-alpine3.15 AS base-builder

RUN apk add --update --no-cache \
    make \
    git
