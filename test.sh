#!/usr/bin/env bash

set -u

cleanup() {
    echo "Cleaning up..."
    docker compose logs > docker-compose.log
    docker compose down
}

trap cleanup EXIT

TEMPORAL_VERSION="${TEMPORAL_VERSION:-latest}"

docker compose up -d

is_ready() {
    docker compose exec temporal-admin-tools temporal operator cluster health 2>/dev/null | grep -q SERVING
}

for _ in $(seq 30); do
    is_ready && break
    sleep 1
done

is_ready 2>&1
RES=$?
if [ "$RES" != "0" ]; then
    docker compose exec temporal-admin-tools temporal operator cluster health
    docker compose logs temporal -tail 10
else
    echo "OK"
fi
exit $RES
