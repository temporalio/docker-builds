FROM registry.access.redhat.com/ubi9/go-toolset:1.23 AS base-builder

USER root

RUN dnf -y upgrade && \
    dnf -y install make git && \
    dnf clean all