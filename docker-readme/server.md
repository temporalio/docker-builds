Temporal requires a database backend -- one of Cassandra (default), MySQL, or PostgreSQL.

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

`CASSANDRA_CERT_DATA` (defaults to unset)

This variable allows you to pass a Cassandra security certificate as an object rather than a file path.

`CASSANDRA_CERT_KEY` (defaults to unset)

This variable specifies the path to your Cassandra security certificate key, if you are using TLS.

`CASSANDRA_CERT_KEY_DATA` (defaults to unset)

This variable allows you to pass a Cassandra security certificate key as an object rather than a file path.

`CASSANDRA_CA` (defaults to unset)

This variable specifies the path to your Cassandra security certificate authority, if needed.

`CASSANDRA_CA_DATA` (defaults to unset)

This variable allows you to pass a Cassandra security certificate authority as an object rather than a file path.

`CASSANDRA_HOST_VERIFICATION` (default: `false`)

This variable specifies whether Cassandra should perform host key verification.

`CASSANDRA_HOST_NAME` (defaults to unset)

This variable specifies the hostname of your Cassandra DB.

`CASSANDRA_ADDRESS_TRANSLATOR` (defaults to unset)

Cassandra drivers have an AddressTranslator interface that can translate IP addresses received from Cassandra nodes into locally queriable addresses. This can be useful in situations where the addresses received from Cassandra nodes are not reachable directly by the driver or are not the preferred address to use.

`CASSANDRA_ADDRESS_TRANSLATOR_OPTIONS` (defaults to unset)

This variable allows you to specify AddressTranslator [options](https://github.com/pingidentity/cassandra-spring-boot-starter/blob/master/README.md)

### MySQL/PostgreSQL

`DBNAME` (defaults to `temporal`)

This variable specifies the name of your MySQL / Postgres database.

`VISIBILITY_DBNAME` (defaults to `temporal_visibility`)

This variable specifies the name of your MySQL / Postgres visibility database, separate from the main Temporal database.

`VISIBILITY_DB_PORT` (defautls to `3306` for MySQL and `5432` for Postgres)

This variable specifies the port to connect to MySQL/PostgrSQL on for your visibility database.

`VISIBILITY_MYSQL_SEEDS` (defaults to unset)

This variable specifies your MySQL hostname for your visibility database.

`VISIBILITY_MYSQL_USER` (defaults to unset)

This variable specifies your MySQL username for your visibility database.

`VISIBILITY_MYSQL_PWD` (defaults to unset)

This variable specifies your MySQL password for your visibility database.

`VISIBILITY_POSTGRES_SEEDS` (defaults to unset)

This variable specifies your PostgreSQL hostname for your visibility database.

`VISIBILITY_POSTGRES_USER` (defaults to unset)

This variable specifies your PostgreSQL username for your visibility database.

`VISIBILITY_POSTGRES_PWD` (defaults to unset)

This variable specifies your PostgreSQL password for your visibility database.
 
`DB_PORT` (defautls to `3306` for MySQL and `5432` for Postgres)

This variable specifies the port to connect to MySQL/PostgreSQL on.

`MYSQL_SEEDS` (defaults to unset)

This variable specifies your MySQL hostname.

`MYSQL_USER` (defaults to unset)

This variable specifies your MySQL username.

`MYSQL_PWD` (defaults to unset)

This variable specifies your MySQL password.

`MYSQL_TX_ISOLATION_COMPAT` (defaults to `false`)

This variable enables compatibility with pre-5.7.20 MySQL installations, if needed.

`SQL_VIS_MAX_CONNS` (defaults to `10`)

This variables specifies the maximum allowed active connections to your visibility database.

`SQL_VIS_MAX_IDLE_CONNS` (defaults to `10`)

This variables specifies the maximum allowed idle connections to your visibility database.

`SQL_VIS_MAX_CONN_TIME` (defaults to `1h`)

This variable specifies how long connections to your visibility database are allowed to remain open.

`SQL_MAX_CONNS` (defaults to `20`)

This variables specifies the maximum allowed active database connections.

`SQL_MAX_IDLE_CONNS` (defaults to `20`)

This variables specifies the maximum allowed idle database connections.

`SQL_MAX_CONN_TIME` (defaults to `1h`)

This variable specifies how long connections to your database are allowed to remain open.

`SQL_TLS_ENABLED` (defaults to `false`)

This variale specifies whether you use TLS to connect to your SQL database.

`SQL_CA` (defaults to unset)

This variable specifies the path to your SQL security certificate authority, if needed.

`SQL_CERT` (defaults to unset)

This variable specifies the path to your SQL security certificate, if needed.

`SQL_CERT_KEY` (defaults to unset)

This variable specifies the path to your SQL security certificate key, if needed.

`SQL_HOST_VERIFICATION` (defaults to `false`)

This variable specifies whether your SQL database connection should perform hostname verification.

`SQL_HOST_NAME` (defaults to unset)

This variable specifies which hostname your database connection should validate against when using TLS.

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

`PPROF_PORT` (defaults to `0`)

`TEMPORAL_TLS_REFRESH_INTERVAL` (defaults to `0s`)

`TEMPORAL_TLS_EXPIRATION_CHECKS_WARNING_WINDOW` (defaults to `0s`)

`TEMPORAL_TLS_EXPIRATION_CHECKS_ERROR_WINDOW` (defaults to `0s`)

`TEMPORAL_TLS_EXPIRATION_CHECKS_CHECK_INTERVAL` (defaults to `0s`)

`TEMPORAL_TLS_REQUIRE_CLIENT_AUTH` (defaults to `false`)

This variable specifies whether Temporal clients (including all Workers, CLI and SDK code) are required to authenticate via TLS.

`TEMPORAL_TLS_SERVER_CERT` (defaults to unset)

This variable specifies the path to your Temporal security certificate, if you are using TLS.

`TEMPORAL_TLS_SERVER_CERT_DATA` (defaults to unset)

This variable allows you to pass a Temporal security certificate as an object rather than a file path.

`TEMPORAL_TLS_SERVER_KEY` (defaults to unset)

This variable specifies the path to your Temporal security certificate key, if you are using TLS.

`TEMPORAL_TLS_SERVER_KEY_DATA` (defaults to unset)

This variable allows you to pass a Temporal security certificate key as an object rather than a file path.

`TEMPORAL_TLS_SERVER_CA_CERT` (defaults to unset)

This variable specifies the path to your Temporal security certificate authority, if needed.

`TEMPORAL_TLS_SERVER_CA_CERT_DATA` (defaults to unset)

This variable allows you to pass a Temporal security certificate authority as an object rather than a file path.

`TEMPORAL_TLS_INTERNODE_DISABLE_HOST_VERIFICATION` (defaults to `false`)

This variable specifies whether Temporal should skip host key verification when connecting to an internode (e.g., the history or matching services).

`TEMPORAL_TLS_INTERNODE_SERVER_NAME` (defaults to unset)

This variable specifies which hostname your internode connection should validate against when using TLS.

`TEMPORAL_TLS_FRONTEND_CERT` (defaults to unset)

This variable specifies the path to your frontend security certificate, if you are using TLS.

`TEMPORAL_TLS_FRONTEND_CERT_DATA` (defaults to unset)

This variable allows you to pass a frontend security certificate as an object rather than a file path.

`TEMPORAL_TLS_FRONTEND_KEY` (defaults to unset)

This variable specifies the path to your frontend security certificate key, if you are using TLS.

`TEMPORAL_TLS_FRONTEND_KEY_DATA` (defaults to unset)

This variable allows you to pass a frontend security certificate key as an object rather than a file path.

`TEMPORAL_TLS_FRONTEND_DISABLE_HOST_VERIFICATION` (defaults to `false`)

This variable specifies whether the frontned should skip host key verification.

`TEMPORAL_TLS_FRONTEND_SERVER_NAME` (defaults to unset)

This variable specifies which hostname your frontend should validate against when using TLS.

`TEMPORAL_TLS_CLIENT1_CA_CERT` (defaults to unset)

`TEMPORAL_TLS_CLIENT1_CA_CERT_DATA` (defaults to unset)

`TEMPORAL_TLS_CLIENT2_CA_CERT` (defaults to unset)

`TEMPORAL_TLS_CLIENT2_CA_CERT_DATA` (defaults to unset)

`STATSD_ENDPOINT` (defaults to unset)

`PROMETHEUS_ENDPOINT` (defaults to unset)

`PROMETHEUS_TIMER_TYPE` (defaults to `histogram`)

`TEMPORAL_JWT_KEY_SOURCE1` (defaults to unset)

`TEMPORAL_JWT_KEY_SOURCE2` (defaults to unset)

`TEMPORAL_JWT_KEY_REFRESH` (defaults to `1m`)

`TEMPORAL_JWT_PERMISSIONS_CLAIM` (defaults to `permissions`)

`TEMPORAL_AUTH_AUTHORIZER` (defaults to unset)

`TEMPORAL_AUTH_CLAIM_MAPPER` (defaults to unset)

`FRONTEND_GRPC_PORT` (defaults to `7233`)

This variable specifies the port that Temporal's frontend service GRPC endpoint is available on.

`FRONTEND_HTTP_PORT` (defaults to `7243`)

This variable specifies the port that Temporal's frontend service HTTP endpoint is available on.

`FRONTEND_MEMBERSHIP_PORT` (defaults to `6933`)

This variable specifies the port that Temporal's frontend service membership endpoint is available on.

`BIND_ON_IP` (defaults to `127.0.0.1` / localhost)

This variable spcifies the URL that the Temporal frontend service should be available at.

`INTERNAL_FRONTEND_GRPC_PORT` (defaults to `7236`)

This variable specifies the port that Temporal's frontend service internal GRPC endpoint is available on.

`INTERNAL_FRONTEND_MEMBERSHIP_PORT` (defaults to `6936`)

This variable specifies the port that Temporal's frontend service internal membership endpoint is available on.

`MATCHING_GRPC_PORT` (defaults to `7235`)

This variable specifies the port that Temporal's matching service GRPC endpoint is available on.

`MATCHING_MEMBERSHIP_PORT` (defaults to `6935`)

This variable specifies the port that Temporal's matching service membership endpoint is available on.

`HISTORY_GRPC_PORT` (defaults to `7234`)

This variable specifies the port that Temporal's history service GRPC endpoint is available on.

`HISTORY_MEMBERSHIP_PORT` (defaults to `6934`)

This variable specifies the port that Temporal's history service membership endpoint is available on.

`WORKER_GRPC_PORT` (defaults to `7239`)

This variable specifies the port that Temporal's worker service GRPC endpoint is available on.

`WORKER_MEMBERSHIP_PORT` (defaults to `6939`)

This variable specifies the port that Temporal's worker service membership endpoint is available on.

`USE_INTERNAL_FRONTEND` (defaults to unset)

`PUBLIC_FRONTEND_ADDRESS` (defaults to unset)

`DYNAMIC_CONFIG_FILE_PATH` (defaults to `/etc/temporal/config/dynamicconfig/docker.yaml`)