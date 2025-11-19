ARG AUTO_SETUP_IMAGE=temporaliotest/auto-setup:latest
ARG GOPROXY

##### Development configuration for Temporal with additional set of tools #####
FROM ${AUTO_SETUP_IMAGE} AS temporal-develop

# apk and setup-develop.sh requires root permissions.
USER root

# iproute2 contains tc, which can be used for traffic shaping in resiliancy testing.
ONBUILD RUN apk add --no-cache iproute2

COPY ./docker/setup-develop.sh /etc/temporal/setup-develop.sh

CMD ["autosetup", "develop"]
