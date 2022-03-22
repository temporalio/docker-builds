ARG AUTO_SETUP_IMAGE=temporaliotest/auto-setup:latest
ARG GOPROXY

##### Development configuration for Temporal with additional set of tools #####
FROM ${AUTO_SETUP_IMAGE} as temporal-develop

# apk and setup-develop.sh requires root permissions.
USER root
# iproute2 contains tc, which can be used for traffic shaping in resiliancy testing. 
ONBUILD RUN apk add iproute2

CMD ["autosetup", "develop"]

COPY ./temporal/docker/setup-develop.sh /etc/temporal/setup-develop.sh
