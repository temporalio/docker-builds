#!/bin/bash

set -eu -o pipefail

# === Auto setup defaults ===

: "${SKIP_SCHEMA_SETUP:=false}"
: "${SKIP_DB_CREATE:=false}"

# Cassandra
: "${KEYSPACE:=temporal}"

: "${CASSANDRA_SEEDS:=}"
: "${CASSANDRA_PORT:=9042}"
: "${CASSANDRA_USER:=}"
: "${CASSANDRA_PASSWORD:=}"
: "${CASSANDRA_TLS_ENABLED:=}"
: "${CASSANDRA_CERT:=}"
: "${CASSANDRA_CERT_KEY:=}"
: "${CASSANDRA_CA:=}"
: "${CASSANDRA_REPLICATION_FACTOR:=1}"

# SQL
: "${SQL_PLUGIN:=}"
: "${SQL_HOST:=}"
if [ $SQL_PLUGIN == "postgres12" || $SQL_PLUGIN == "postgres12_pgx" ]; then
    DEFAULT_SQL_PORT=5432
elif [ $SQL_PLUGIN == "mysql8" ]; then
    DEFAULT_SQL_PORT=3306
fi
: "${SQL_PORT:=$DEFAULT_SQL_PORT}"
: "${SQL_USER:=}"
: "${SQL_PASSWORD:=}"
: "${SQL_CONNECT_ATTRIBUTES:=}"
: "${SQL_DATABASE:=temporal}"
: "${SQL_VISIBILITY_DATABASE:=temporal_visibility}"

# Elasticsearch
: "${ENABLE_ES:=false}"
: "${ES_SCHEME:=http}"
: "${ES_SEEDS:=}"
: "${ES_PORT:=9200}"
: "${ES_USER:=}"
: "${ES_PWD:=}"
: "${ES_VERSION:=v7}"
: "${ES_VIS_INDEX:=temporal_visibility_v1_dev}"
: "${ES_SEC_VIS_INDEX:=}"
: "${ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS:=0}"

# Server setup
: "${TEMPORAL_ADDRESS:=}"
# TEMPORAL_CLI_ADDRESS is deprecated and support for it will be removed in the future release.
: "${TEMPORAL_CLI_ADDRESS:=}"

: "${SKIP_DEFAULT_NAMESPACE_CREATION:=false}"
: "${DEFAULT_NAMESPACE:=default}"
: "${DEFAULT_NAMESPACE_RETENTION:=24h}"

: "${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES:=false}"

# === Helper functions ===

die() {
    echo "$*" 1>&2
    exit 1
}

# === Main database functions ===

validate_db_env() {
    case ${SQL_PLUGIN} in
    mysql8 | postgres12 | postgres12_pgx)
        if [[ -z ${SQL_HOST} ]]; then
            die "SQL_HOST env must be set when using SQL."
        fi
        ;;
    "")
        if [[ -z ${CASSANDRA_SEEDS} ]]; then
            die "CASSANDRA_SEEDS env must be set when using Cassandra."
        fi
        ;;
    *)
        die "Unsupported SQL plugin specified: 'SQL_PLUGIN=${SQL_PLUGIN}'. Valid plugins are: mysql8, postgres12, postgres12_pgx"
        ;;
    esac
}

wait_for_cassandra() {
    # TODO (alex): Remove exports
    export CASSANDRA_USER=${CASSANDRA_USER}
    export CASSANDRA_PORT=${CASSANDRA_PORT}
    export CASSANDRA_ENABLE_TLS=${CASSANDRA_TLS_ENABLED}
    export CASSANDRA_TLS_CERT=${CASSANDRA_CERT}
    export CASSANDRA_TLS_KEY=${CASSANDRA_CERT_KEY}
    export CASSANDRA_TLS_CA=${CASSANDRA_CA}

    export CASSANDRA_PASSWORD=${CASSANDRA_PASSWORD}

    until temporal-cassandra-tool --ep "${CASSANDRA_SEEDS}" validate-health; do
        echo 'Waiting for Cassandra to start up.'
        sleep 1
    done
    echo 'Cassandra started.'
}

wait_for_mysql() {
    until nc -z "${SQL_HOST}" "${SQL_PORT}"; do
        echo 'Waiting for MySQL to start up.'
        sleep 1
    done

    echo 'MySQL started.'
}

wait_for_postgres() {
    until nc -z "${SQL_HOST}" "${SQL_PORT}"; do
        echo 'Waiting for PostgreSQL to startup.'
        sleep 1
    done

    echo 'PostgreSQL started.'
}

wait_for_db() {
    case ${SQL_PLUGIN} in
      mysql8)
          wait_for_mysql
          ;;
      postgres12 | postgres12_pgx)
          wait_for_postgres
          ;;
      "")
          wait_for_cassandra
          ;;
      *)
          die "Unsupported SQL plugin: ${SQL_PLUGIN}."
          ;;
    esac
}

setup_cassandra_schema() {
    # TODO (alex): Remove exports
    export CASSANDRA_USER=${CASSANDRA_USER}
    export CASSANDRA_PORT=${CASSANDRA_PORT}
    export CASSANDRA_ENABLE_TLS=${CASSANDRA_TLS_ENABLED}
    export CASSANDRA_TLS_CERT=${CASSANDRA_CERT}
    export CASSANDRA_TLS_KEY=${CASSANDRA_CERT_KEY}
    export CASSANDRA_TLS_CA=${CASSANDRA_CA}

    export CASSANDRA_PASSWORD=${CASSANDRA_PASSWORD}

    SCHEMA_DIR=${TEMPORAL_HOME}/schema/cassandra/temporal/versioned
    if [[ ${SKIP_DB_CREATE} != true ]]; then
        temporal-cassandra-tool --ep "${CASSANDRA_SEEDS}" create -k "${KEYSPACE}" --rf "${CASSANDRA_REPLICATION_FACTOR}"
    fi
    temporal-cassandra-tool --ep "${CASSANDRA_SEEDS}" -k "${KEYSPACE}" setup-schema -v 0.0
    temporal-cassandra-tool --ep "${CASSANDRA_SEEDS}" -k "${KEYSPACE}" update-schema -d "${SCHEMA_DIR}"
}

setup_mysql_schema() {
    if [[ ${MYSQL_TX_ISOLATION_COMPAT} == true ]]; then
        if [ -z ${SQL_CONNECT_ATTRIBUTES} ]; then
            export SQL_CONNECT_ATTRIBUTES="tx_isolation=READ-COMMITTED"
        else
            export SQL_CONNECT_ATTRIBUTES="$SQL_CONNECT_ATTRIBUTES&tx_isolation=READ-COMMITTED"
        fi
    fi

    MYSQL_VERSION_DIR=v8
    SCHEMA_DIR=${TEMPORAL_HOME}/schema/mysql/${MYSQL_VERSION_DIR}/temporal/versioned
    if [[ ${SKIP_DB_CREATE} != true ]]; then
        temporal-sql-tool create
    fi
    temporal-sql-tool setup-schema -v 0.0
    temporal-sql-tool update-schema -d "${SCHEMA_DIR}"

    # Only setup visibility schema if ES is not enabled
    if [[ ${ENABLE_ES} == false ]]; then
      VISIBILITY_SCHEMA_DIR=${TEMPORAL_HOME}/schema/mysql/${MYSQL_VERSION_DIR}/visibility/versioned
      if [[ ${SKIP_DB_CREATE} != true ]]; then
          temporal-sql-tool  --db "${VISIBILITY_DBNAME}" create
      fi
      temporal-sql-tool --db "${SQL_VISIBILITY_DATABASE}" setup-schema -v 0.0
      temporal-sql-tool --db "${SQL_VISIBILITY_DATABASE}" update-schema -d "${VISIBILITY_SCHEMA_DIR}"
    fi
}

setup_postgres_schema() {
    POSTGRES_VERSION_DIR=v12
    SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/${POSTGRES_VERSION_DIR}/temporal/versioned
    # Create database only if its name is different from the user name. Otherwise PostgreSQL container itself will create database.
    if [[ ${SQL_DATABASE} != "${SQL_USER}" && ${SKIP_DB_CREATE} != true ]]; then
        temporal-sql-tool create
    fi
    temporal-sql-tool setup-schema -v 0.0
    temporal-sql-tool update-schema -d "${SCHEMA_DIR}"

    # Only setup visibility schema if ES is not enabled
    if [[ ${ENABLE_ES} == false ]]; then
      VISIBILITY_SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/${POSTGRES_VERSION_DIR}/visibility/versioned
      if [[ ${VISIBILITY_DBNAME} != "${POSTGRES_USER}" && ${SKIP_DB_CREATE} != true ]]; then
          temporal-sql-tool --db "${SQL_VISIBILITY_DATABASE}" create
      fi
      temporal-sql-tool --db "${SQL_VISIBILITY_DATABASE}" setup-schema -v 0.0
      temporal-sql-tool --db "${SQL_VISIBILITY_DATABASE}" update-schema -d "${VISIBILITY_SCHEMA_DIR}"
    fi
}

setup_schema() {
    case ${SQL_PLUGIN} in
      mysql8)
          echo 'Setup MySQL schema.'
          setup_mysql_schema
          ;;
      postgres12 | postgres12_pgx)
          echo 'Setup PostgreSQL schema.'
          setup_postgres_schema
          ;;
      "")
          echo 'Setup Cassandra schema.'
          setup_cassandra_schema
          ;;
      *)
          die "Unsupported SQL plugin: ${SQL_PLUGIN}."
          ;;
    esac
}

# === Elasticsearch functions ===

validate_es_env() {
    if [[ ${ENABLE_ES} == true ]]; then
        if [[ -z ${ES_SEEDS} ]]; then
            die "ES_SEEDS env must be set if ENABLE_ES is ${ENABLE_ES}"
        fi
    fi
}

wait_for_es() {
    SECONDS=0

    ES_SERVER="${ES_SCHEME}://${ES_SEEDS%%,*}:${ES_PORT}"

    until curl --silent --fail --user "${ES_USER}":"${ES_PWD}" "${ES_SERVER}" >& /dev/null; do
        DURATION=${SECONDS}

        if [[ ${ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS} -gt 0 && ${DURATION} -ge "${ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS}" ]]; then
            echo 'WARNING: timed out waiting for Elasticsearch to start up. Skipping index creation.'
            return;
        fi

        echo 'Waiting for Elasticsearch to start up.'
        sleep 1
    done

    echo 'Elasticsearch started.'
}

setup_es_index() {
    ES_SERVER="${ES_SCHEME}://${ES_SEEDS%%,*}:${ES_PORT}"
# @@@SNIPSTART setup-es-template-commands
    # ES_SERVER is the URL of Elasticsearch server i.e. "http://localhost:9200".
    SETTINGS_URL="${ES_SERVER}/_cluster/settings"
    SETTINGS_FILE=${TEMPORAL_HOME}/schema/elasticsearch/visibility/cluster_settings_${ES_VERSION}.json
    TEMPLATE_URL="${ES_SERVER}/_template/temporal_visibility_v1_template"
    SCHEMA_FILE=${TEMPORAL_HOME}/schema/elasticsearch/visibility/index_template_${ES_VERSION}.json
    INDEX_URL="${ES_SERVER}/${ES_VIS_INDEX}"
    curl --fail --user "${ES_USER}":"${ES_PWD}" -X PUT "${SETTINGS_URL}" -H "Content-Type: application/json" --data-binary "@${SETTINGS_FILE}" --write-out "\n"
    curl --fail --user "${ES_USER}":"${ES_PWD}" -X PUT "${TEMPLATE_URL}" -H 'Content-Type: application/json' --data-binary "@${SCHEMA_FILE}" --write-out "\n"
    curl --user "${ES_USER}":"${ES_PWD}" -X PUT "${INDEX_URL}" --write-out "\n"
    if [[ -n "${ES_SEC_VIS_INDEX}" ]]; then
      SEC_INDEX_URL="${ES_SERVER}/${ES_SEC_VIS_INDEX}"
      curl --user "${ES_USER}":"${ES_PWD}" -X PUT "${SEC_INDEX_URL}" --write-out "\n"
    fi
# @@@SNIPEND
}

# === Server setup ===

register_default_namespace() {
    echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
    if ! temporal operator namespace describe "${DEFAULT_NAMESPACE}"; then
        echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
        temporal operator namespace create --retention "${DEFAULT_NAMESPACE_RETENTION}" --description "Default namespace for Temporal Server." "${DEFAULT_NAMESPACE}"
        echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
    else
        echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
    fi
}

add_custom_search_attributes() {
    until temporal operator search-attribute list --namespace "${DEFAULT_NAMESPACE}"; do
      echo "Waiting for namespace cache to refresh..."
      sleep 1
    done
    echo "Namespace cache refreshed."

    echo "Adding Custom*Field search attributes."
    # TODO: Remove CustomStringField
# @@@SNIPSTART add-custom-search-attributes-for-testing-command
    temporal operator search-attribute create --namespace "${DEFAULT_NAMESPACE}" \
        --name CustomKeywordField --type Keyword \
        --name CustomStringField --type Text \
        --name CustomTextField --type Text \
        --name CustomIntField --type Int \
        --name CustomDatetimeField --type Datetime \
        --name CustomDoubleField --type Double \
        --name CustomBoolField --type Bool
# @@@SNIPEND
}

setup_server(){
    echo "Temporal CLI address: ${TEMPORAL_ADDRESS}."

    until temporal operator cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    if [[ ${SKIP_DEFAULT_NAMESPACE_CREATION} != true ]]; then
        register_default_namespace
    fi

    if [[ ${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES} != true ]]; then
        add_custom_search_attributes
    fi
}

# === Main ===

if [[ ${SKIP_SCHEMA_SETUP} != true ]]; then
    validate_db_env
    wait_for_db
    setup_schema
fi

if [[ ${ENABLE_ES} == true ]]; then
    validate_es_env
    wait_for_es
    setup_es_index
fi

# Run this func in parallel process. It will wait for server to start and then run required steps.
setup_server &
