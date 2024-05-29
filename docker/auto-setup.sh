#!/bin/bash

set -eu -o pipefail

# === Auto setup defaults ===

: "${SKIP_SCHEMA_SETUP:=false}"
: "${SKIP_DB_CREATE:=false}"

# Cassandra
: "${KEYSPACE:=}"
if [ -n "${KEYSPACE}" ]; then
    echo "The KEYSPACE environment variable is deprecated. Please set CASSANDRA_KEYSPACE=${KEYSPACE} instead." >&2
    CASSANDRA_KEYSPACE="${KEYSPACE}"
fi
: "${CASSANDRA_KEYSPACE:=temporal}"
: "${CASSANDRA_SEEDS:=}"
: "${CASSANDRA_PORT:=9042}"
: "${CASSANDRA_USER:=}"
: "${CASSANDRA_PASSWORD:=}"
: "${CASSANDRA_TLS_ENABLED:=}"
if [ -n "${CASSANDRA_TLS_ENABLED}" ]; then
    echo "The CASSANDRA_TLS_ENABLED environment variable is deprecated. Please set CASSANDRA_ENABLE_TLS=${CASSANDRA_TLS_ENABLED} instead." >&2
    CASSANDRA_ENABLE_TLS="${CASSANDRA_TLS_ENABLED}"
fi
: "${CASSANDRA_ENABLE_TLS:=}"
: "${CASSANDRA_CERT:=}"
if [ -n "${CASSANDRA_CERT}" ]; then
    echo "The CASSANDRA_CERT environment variable is deprecated. Please set CASSANDRA_TLS_CERT=${CASSANDRA_CERT} instead." >&2
    CASSANDRA_TLS_CERT="${CASSANDRA_CERT}"
fi
: "${CASSANDRA_TLS_CERT:=}"
: "${CASSANDRA_CERT_KEY:=}"
if [ -n "${CASSANDRA_CERT_KEY}" ]; then
    echo "The CASSANDRA_CERT_KEY environment variable is deprecated. Please set CASSANDRA_TLS_CERT=${CASSANDRA_CERT_KEY} instead." >&2
    CASSANDRA_TLS_CERT_KEY="${CASSANDRA_CERT_KEY}"
fi
: "${CASSANDRA_TLS_KEY:=}"
: "${CASSANDRA_CA:=}"
if [ -n "${CASSANDRA_CA}" ]; then
    echo "The CASSANDRA_CA environment variable is deprecated. Please set CASSANDRA_TLS_CA=${CASSANDRA_CA} instead." >&2
    CASSANDRA_TLS_CA="${CASSANDRA_CA}"
fi
: "${CASSANDRA_TLS_CA:=}"
: "${CASSANDRA_REPLICATION_FACTOR:=1}"

export CASSANDRA_SEEDS CASSANDRA_PORT CASSANDRA_USER CASSANDRA_PASSWORD CASSANDRA_KEYSPACE \
    CASSANDRA_ENABLE_TLS CASSANDRA_TLS_CERT CASSANDRA_TLS_KEY CASSANDRA_TLS_CA CASSANDRA_REPLICATION_FACTOR

# SQL
: "${DB:=}"
if [ -n "${DB}" ]; then
    if [ ${DB} == "cassandra" ]; then
        echo "The DB environment variable is deprecated. Please unset DB, cassandra is the default." >&2
    else
        echo "The DB environment variable is deprecated. Please set SQL_PLUGIN=${DB} instead." >&2
        SQL_PLUGIN="${DB}"
    fi
fi
: "${SQL_PLUGIN:=}"
: "${POSTGRES_SEEDS:=}"
if [ -n "${POSTGRES_SEEDS}" ]; then
    echo "The POSTGRES_SEEDS environment variable is deprecated. Please set SQL_HOST=${POSTGRES_SEEDS} instead." >&2
    SQL_HOST="${POSTGRES_SEEDS}"
fi
: "${MYSQL_SEEDS:=}"
if [ -n "${MYSQL_SEEDS}" ]; then
    echo "The MYSQL_SEEDS environment variable is deprecated. Please set SQL_HOST=${MYSQL_SEEDS} instead." >&2
    SQL_HOST="${MYSQL_SEEDS}"
fi
: "${SQL_HOST:=}"
if [ $SQL_PLUGIN == "postgres12" ] || [ $SQL_PLUGIN == "postgres12_pgx" ]; then
    DEFAULT_SQL_PORT=5432
elif [ $SQL_PLUGIN == "mysql8" ]; then
    DEFAULT_SQL_PORT=3306
fi
: "${DB_PORT:=}"
if [ -n "${DB_PORT}" ]; then
    echo "The DB_PORT environment variable is deprecated. Please set SQL_PORT=${DB_PORT} instead." >&2
    SQL_PORT="${DB_PORT}"
fi
: "${SQL_PORT:=$DEFAULT_SQL_PORT}"
: "${POSTGRES_USER:=}"
if [ -n "${POSTGRES_USER}" ]; then
    echo "The POSTGRES_USER environment variable is deprecated. Please set SQL_USER=${POSTGRES_USER} instead." >&2
    SQL_USER="${POSTGRES_USER}"
fi
: "${MYSQL_USER:=}"
if [ -n "${MYSQL_USER}" ]; then
    echo "The MYSQL_USER environment variable is deprecated. Please set SQL_USER=${MYSQL_USER} instead." >&2
    SQL_USER="${MYSQL_USER}"
fi
: "${SQL_USER:=}"
: "${POSTGRES_PWD:=}"
if [ -n "${POSTGRES_PWD}" ]; then
    echo "The POSTGRES_PWD environment variable is deprecated. Please set SQL_PASSWORD instead." >&2
    SQL_PASSWORD="${POSTGRES_PWD}"
fi
: "${MYSQL_PWD:=}"
if [ -n "${MYSQL_PWD}" ]; then
    echo "The MYSQL_PWD environment variable is deprecated. Please set SQL_PASSWORD instead." >&2
    SQL_PASSWORD="${MYSQL_PWD}"
fi
: "${SQL_PASSWORD:=}"
: "${SQL_CONNECT_ATTRIBUTES:=}"
: "${MYSQL_TX_ISOLATION_COMPAT:=false}"
if [[ ${MYSQL_TX_ISOLATION_COMPAT} == true ]]; then
    echo "The MYSQL_TX_ISOLATION_COMPAT environment variable is deprecated. Please set SQL_CONNECT_ATTRIBUTES=\"tx_isolation=READ-COMMITTED\" instead." >&2
    if [ -z ${SQL_CONNECT_ATTRIBUTES} ]; then
        SQL_CONNECT_ATTRIBUTES="tx_isolation=READ-COMMITTED"
    else
        SQL_CONNECT_ATTRIBUTES="$SQL_CONNECT_ATTRIBUTES&tx_isolation=READ-COMMITTED"
    fi
fi
: "${DBNAME:=}"
if [ -n "${DBNAME}" ]; then
    echo "The DBNAME environment variable is deprecated. Please set SQL_DATABASE=${DBNAME} instead." >&2
    SQL_DATABASE="${DBNAME}"
fi
: "${SQL_DATABASE:=temporal}"
: "${VISIBILITY_DBNAME:=}"
if [ -n "${VISIBILITY_DBNAME}" ]; then
    echo "The VISIBILITY_DBNAME environment variable is deprecated. Please set SQL_VISIBILITY_DATABASE=${VISIBILITY_DBNAME} instead." >&2
    SQL_VISIBILITY_DATABASE="${VISIBILITY_DBNAME}"
fi
: "${SQL_VISIBILITY_DATABASE:=temporal_visibility}"
: "${POSTGRES_TLS_ENABLED:=false}"
if [ -n "${POSTGRES_TLS_ENABLED}" ]; then
    echo "The POSTGRES_TLS_ENABLED environment variable is deprecated. Please set SQL_TLS=${POSTGRES_TLS_ENABLED} instead." >&2
    SQL_TLS="${POSTGRES_TLS_ENABLED}"
fi
: "${SQL_TLS:=false}"
: "${POSTGRES_TLS_DISABLE_HOST_VERIFICATION:=false}"
if [ -n "${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}" ]; then
    echo "The POSTGRES_TLS_DISABLE_HOST_VERIFICATION environment variable is deprecated. Please set SQL_TLS_DISABLE_HOST_VERIFICATION=${POSTGRES_TLS_DISABLE_HOST_VERIFICATION} instead." >&2
    SQL_TLS_DISABLE_HOST_VERIFICATION="${POSTGRES_TLS_DISABLE_HOST_VERIFICATION}"
fi
: "${SQL_TLS_DISABLE_HOST_VERIFICATION:=false}"
: "${POSTGRES_TLS_CERT_FILE:=}"
if [ -n "${POSTGRES_TLS_CERT_FILE}" ]; then
    echo "The POSTGRES_TLS_CERT_FILE environment variable is deprecated. Please set SQL_TLS_CERT_FILE=${POSTGRES_TLS_CERT_FILE} instead." >&2
    SQL_TLS_CERT_FILE="${POSTGRES_TLS_CERT_FILE}"
fi
: "${SQL_TLS_CERT_FILE:=}"
: "${POSTGRES_TLS_KEY_FILE:=}"
if [ -n "${POSTGRES_TLS_KEY_FILE}" ]; then
    echo "The POSTGRES_TLS_KEY_FILE environment variable is deprecated. Please set SQL_TLS_KEY_FILE=${POSTGRES_TLS_KEY_FILE} instead." >&2
    SQL_TLS_KEY_FILE="${POSTGRES_TLS_KEY_FILE}"
fi
: "${SQL_TLS_KEY_FILE:=}"
: "${POSTGRES_TLS_CA_FILE:=}"
if [ -n "${POSTGRES_TLS_CA_FILE}" ]; then
    echo "The POSTGRES_TLS_CA_FILE environment variable is deprecated. Please set SQL_TLS_CA_FILE=${POSTGRES_TLS_CA_FILE} instead." >&2
    SQL_TLS_CA_FILE="${POSTGRES_TLS_CA_FILE}"
fi
: "${SQL_TLS_CA_FILE:=}"
: "${POSTGRES_TLS_SERVER_NAME:=}"
if [ -n "${POSTGRES_TLS_SERVER_NAME}" ]; then
    echo "The POSTGRES_TLS_SERVER_NAME environment variable is deprecated. Please set SQL_TLS_SERVER_NAME=${POSTGRES_TLS_SERVER_NAME} instead." >&2
    SQL_TLS_SERVER_NAME="${POSTGRES_TLS_SERVER_NAME}"
fi
: "${SQL_TLS_SERVER_NAME:=}"

export SQL_PLUGIN SQL_HOST SQL_PORT SQL_USER SQL_PASSWORD SQL_DATABASE SQL_VISIBILITY_DATABASE SQL_CONNECT_ATTRIBUTES \
    SQL_TLS SQL_TLS_DISABLE_HOST_VERIFICATION SQL_TLS_CERT_FILE SQL_TLS_KEY_FILE SQL_TLS_CA_FILE SQL_TLS_SERVER_NAME

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
    until temporal-cassandra-tool validate-health; do
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
