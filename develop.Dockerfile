# temporaliotest/auto-setup is an ephemeral CI-test registry (thousands of per-commit SHA tags,
# no stable/semver channel), so ":latest" is the only sensible default for local dev builds here
# -- pinning to a specific SHA would go stale immediately with no equivalent to bump it to.
ARG AUTO_SETUP_IMAGE=temporaliotest/auto-setup:latest
ARG GOPROXY

##### Development configuration for Temporal with additional set of tools #####
# trivy:ignore:DS-0001
FROM ${AUTO_SETUP_IMAGE} AS temporal-develop

# apk and setup-develop.sh require root permissions, and setup-develop.sh's `tc` traffic-shaping
# calls need root/CAP_NET_ADMIN at container runtime too, so this stays root through CMD.
# Dev/test-only image, not used in production deployments.
# hadolint ignore=DL3002
USER root

# iproute2 contains tc, which can be used for traffic shaping in resiliancy testing.
ONBUILD RUN apk add --no-cache iproute2=6.17.0-r0

COPY ./docker/setup-develop.sh /etc/temporal/setup-develop.sh

CMD ["autosetup", "develop"]
