Temporal requires a database backend -- one of Cassandra (default), MySQL, PostgreSQL, or SQLite.

Optionally also supports Elasticsearch for [visibility](https://docs.temporal.io/self-hosted-guide/visibility).

This is the official Temporal server Docker image. For more `docker-compose` files, refer to the [docker-compose](https://github.com/temporalio/docker-compose) Github repository.

## Environment Variables

`DB` (default: `cassandra`)

This variable specifies the type of database you're connecting to. Allowed values are `cassandra`, `mysql8`, and `postgres12`.

### Cassandra

These options only apply to the Cassandra database backend.

`KEYSPACE` (default: `temporal`)

This variable specifies the name of your Cassandra keyspace.

`CASSANDRA_SEEDS` (defaults to unset)

This variable specifies your Cassndra hostname.

`CASSANDRA_PORT` (default: 9042)

This variable specifies the port to connect to Cassandra on.

`CASSANDRA_USER` (defaults to unset)

This variable specifies your Cassandra username.

`CASSANDRA_PASSWORD` (defaults to unset)

This variable specifies your Cassandra password.

`CASSANDRA_TLS_ENABLED` (default: `false`)

This variable specifies whether you are using TLS to connect to Cassandra.

`CASSANDRA_CERT` (defaults to unset)

This variable specifies the path to your Cassandra security certificate, if you are using TLS.

`CASSANDRA_CERT_DATA`

`CASSANDRA_CERT_KEY` (defaults to unset)

This variable specifies the path to your Cassandra security certificate key, if you are using TLS.

`CASSANDRA_CERT_KEY_DATA`

`CASSANDRA_CA` (defaults to unset)

`CASSANDRA_CA_DATA` 

This variable specifies the host of your Cassandra security certificate authority, if needed.

`CASSANDRA_HOST_VERIFICATION`

`CASSANDRA_HOST_NAME`

`CASSANDRA_ADDRESS_TRANSLATOR`

`CASSANDRA_ADDRESS_TRANSLATOR_OPTIONS`

### MySQL/PostgreSQL

`DBNAME` (defaults to `temporal`)

This variable specifies the name of your MySQL / Postgres database.

`VISIBILITY_DBNAME` (defaults to `temporal_visibility`)

This variable specifies the name of your MySQL / Postgres visibility database, separate from the main Temporal database.

`VISIBILITY_DB_PORT`

`VISIBILITY_MYSQL_SEEDS`

`VISIBILITY_MYSQL_USER`

`VISIBILITY_MYSQL_PWD`

`VISIBILITY_POSTGRES_SEEDS`

`VISIBILITY_POSTGRES_USER`

`VISIBILITY_POSTGRES_PWD`

`DB_PORT` (defautls to `3306`)

This variable specifies the port to connect to MySQL/PostgreSQL on.

`MYSQL_SEEDS` (defaults to unset)

This variable specifies your MySQL hostname.

`MYSQL_USER` (defaults to unset)

This variable specifies your MySQL username.

`MYSQL_PWD` (defaults to unset)

This variable specifies your MySQL password.

`MYSQL_TX_ISOLATION_COMPAT` (defaults to `false`)

This variable enables compatibility with pre-5.7.20 MySQL installations, if needed.

`SQL_VIS_MAX_CONNS`

`SQL_VIS_MAX_IDLE_CONNS`

`SQL_VIS_MAX_CONN_TIME`

`SQL_TLS_ENABLED`

`SQL_CA`

`SQL_CERT`

`SQL_CERT_KEY`

`SQL_HOST_VERIFICATION`

`SQL_HOST_NAME`

`POSTGRES_SEEDS` (defaults to unset)

This variable specifies your Postgres hostname.

`POSTGRES_USER` (defaults to unset)

This variable specifies your PostgreSQL username.

`POSTGRES_PWD` (defaults to unset)

This variable specifies your PostgreSQL password.

`POSTGRES_TLS_ENABLED` (defaults to `false`)

This variable specifies whether you are using TLS to connect to Postgres.

`POSTGRES_TLS_DISABLE_HOST_VERIFICATION` (defaults to `false`)

This variable specifies whether Postgres should skip host key verification (e.g. if you can't easily verify server certs when using Amazon RDS).

`POSTGRES_TLS_CERT_FILE` (defaults to unset)

This variable specifies the path to your Postgres security certificate, if you are using TLS.

`POSTGRES_TLS_KEY_FILE` (defaults to unset)

This variable specifies the path to your Postgres security certificate key, if you are using TLS.

`POSTGRES_TLS_CA_FILE` (defaults to unset)

This variable specifies the path to your Postgres security certificate authority, if needed.

`POSTGRES_TLS_SERVER_NAME` (defaults to unset)

This variable specifies the host of your Postgres TLS server, if needed.

### Elasticsearch

`ENABLE_ES` (defaults to `false`)

This variable specifies whether you are using Elasticsearch.

`ES_SCHEME` (defaults to `http`)

This variable specifies how you are connecting to Elasticsearch. Allowed values are `http` and `https`.

`ES_SEEDS` (defaults to unset)

This variable specifies a comma-separated list of Elasticsearch nodes.

`ES_PORT` (defaults to `9200`)

This variable specifies the port to connect to Elasticsearch on.

`ES_USER` (defaults to unset)

This variable specifies your Elasticsearch username.

`ES_PWD` (defaults to unset)

This variable specifies your Elasticsearch password.

`ES_VERSION` (defaults to `v7`)

This variable specifies your Elasticsearch version.

`ES_VIS_INDEX` (defaults to `temporal_visibility_v1_dev`)

This variable specifies the name of your Elasticsearch index.

`ES_SEC_VIS_INDEX` (defaults to unset)

This variable specifies the name of your [secondary visibility](https://docs.temporal.io/self-hosted-guide/visibility#dual-visibility) Elasticsearch index.

### Server configuration

`TEMPORAL_BROADCAST_ADDRESS` (defaults to unset)

`PPROF_PORT`

`TEMPORAL_TLS_REFRESH_INTERVAL`

`TEMPORAL_TLS_EXPIRATION_CHECKS_WARNING_WINDOW`

`TEMPORAL_TLS_EXPIRATION_CHECKS_ERROR_WINDOW`

`TEMPORAL_TLS_EXPIRATION_CHECKS_CHECK_INTERVAL`

`TEMPORAL_TLS_REQUIRE_CLIENT_AUTH`

`TEMPORAL_TLS_SERVER_CERT`

`TEMPORAL_TLS_SERVER_CERT_DATA`

`TEMPORAL_TLS_SERVER_KEY`

`TEMPORAL_TLS_SERVER_KEY_DATA`

`TEMPORAL_TLS_SERVER_CA_CERT`

`TEMPORAL_TLS_SERVER_CA_CERT_DATA`

`TEMPORAL_TLS_INTERNODE_SERVER_NAME`

`TEMPORAL_TLS_INTERNODE_DISABLE_HOST_VERIFICATION`

`TEMPORAL_TLS_FRONTEND_CERT`

`TEMPORAL_TLS_FRONTEND_CERT_DATA`

`TEMPORAL_TLS_FRONTEND_KEY`

`TEMPORAL_TLS_FRONTEND_KEY_DATA`

`TEMPORAL_TLS_FRONTEND_SERVER_NAME`

`TEMPORAL_TLS_FRONTEND_DISABLE_HOST_VERIFICATION`

`TEMPORAL_TLS_CLIENT1_CA_CERT`

`TEMPORAL_TLS_CLIENT1_CA_CERT_DATA`

`TEMPORAL_TLS_CLIENT2_CA_CERT`

`TEMPORAL_TLS_CLIENT2_CA_CERT_DATA`

`STATSD_ENDPOINT`

`PROMETHEUS_ENDPOINT`

`PROMETHEUS_TIMER_TYPE`

`PROMETHEUS_ENDPOINT`

`TEMPORAL_JWT_KEY_SOURCE1`

`TEMPORAL_JWT_KEY_SOURCE2`

`TEMPORAL_JWT_KEY_REFRESH`

`TEMPORAL_JWT_PERMISSIONS_CLAIM`

`TEMPORAL_AUTH_AUTHORIZER`

`TEMPORAL_AUTH_CLAIM_MAPPER`

`FRONTEND_GRPC_PORT`

`FRONTEND_HTTP_PORT`

`FRONTEND_MEMBERSHIP_PORT`

`BIND_ON_IP`

`INTERNAL_FRONTEND_GRPC_PORT`

`INTERNAL_FRONTEND_MEMBERSHIP_PORT`

`MATCHING_GRPC_PORT`

`MATCHING_MEMBERSHIP_PORT`

`HISTORY_GRPC_PORT`

`HISTORY_MEMBERSHIP_PORT`

`WORKER_GRPC_PORT`

`WORKER_MEMBERSHIP_PORT`

`USE_INTERNAL_FRONTEND`

`PUBLIC_FRONTEND_ADDRESS`

`DYNAMIC_CONFIG_FILE_PATH`