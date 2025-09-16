FROM registry.access.redhat.com/ubi9/go-toolset:1.23 AS base-ci-builder

USER root

# Install what we can from UBI repos
RUN dnf -y upgrade && \
    dnf -y install \
        make \
        git \
        gcc \
        gcc-c++ \
        sed \
        unzip && \
    dnf clean all

# Manually install shellcheck
RUN curl -sSL https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.linux.x86_64.tar.xz | \
    tar -xJ && \
    cp shellcheck-v0.9.0/shellcheck /usr/local/bin/ && \
    chmod +x /usr/local/bin/shellcheck && \
    rm -rf shellcheck-v0.9.0*

# Manually install protoc (protobuf compiler)
RUN curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v24.4/protoc-24.4-linux-x86_64.zip -o protoc.zip && \
    unzip protoc.zip -d /usr/local && \
    chmod +x /usr/local/bin/protoc && \
    rm -f protoc.zip

