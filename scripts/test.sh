#!/usr/bin/env bash

set -u

# shellcheck disable=SC2317
# https://github.com/koalaman/shellcheck/issues/2542
cleanup() {
    echo "Cleaning up..."
    docker compose logs > docker-compose.log
    docker compose down >/dev/null 2>&1
}

trap cleanup EXIT

IMAGE_SHA_TAG="${IMAGE_SHA_TAG:-latest}"

docker compose up -d >/dev/null 2>&1

is_ready() {
    docker compose exec temporal-admin-tools temporal operator cluster health 2>/dev/null | grep -q SERVING
}

for _ in $(seq 60); do
    is_ready && break
    sleep 1
done

is_ready 2>&1
RES=$?
if [ "$RES" != "0" ]; then
    docker compose exec temporal-admin-tools temporal operator cluster health
    docker compose logs temporal --tail 20
else
    echo "OK"
fi
exit $RES
