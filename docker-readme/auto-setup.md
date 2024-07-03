Temporal requires an RDBMS backend; this Docker setup script supports Cassandra (default), MySQL, or PostgreSQL.

Optionally also supports Elasticsearch for [visibility](https://docs.temporal.io/self-hosted-guide/visibility).

## Environment Variables

`DB` (default: `cassandra`)

This variable specifies the type of database you're connecting to. Allowed values are `cassandra`, `mysql`, and `postgres`.

`SKIP_SCHEMA_SETUP` (default: `false`)

This variable specifies whether database schema creation should be skipped. Set this to true if you're using an existing schema.

`SKIP_DB_CREATE` (default: `false`)

This variable specifies whether database creation should be skipped. Set this to true if you're using an existing database.

### Cassandra

These options only apply to the Cassandra database backend.

`KEYSPACE` (default: `temporal`)

This variable specifies the name of your Cassandra keyspace.

`CASSANDRA_SEEDS` (defaults to unset)

`CASSANDRA_PORT` (default: 9042)

This variable specifies the port to connect to Cassandra on.

`CASSANDRA_USER` (defaults to unset)

This variable specifies your Cassandra username.

`CASSANDRA_PASSWORD` (defaults to unset)

This variable specifies your Cassandra password.

`CASSANDRA_TLS_ENABLED` (defaults to unset)

`CASSANDRA_CERT` (defaults to unset)

`CASSANDRA_CERT_KEY` (defaults to unset)

`CASSANDRA_CA` (defaults to unset)

`CASSANDRA_REPLICATION_FACTOR` (defaults to `1`)

### MySQL/PostgreSQL

`DBNAME` (defaults to `temporal`)

`VISIBILITY_DBNAME` (defaults to `temporal_visibility`)

`DB_PORT` (defautls to `3306`)

This variable specifies the port to connect to MySQL/PostgreSQL on.

`MYSQL_SEEDS` (defaults to unset)

`MYSQL_USER` (defaults to unset)

This variable specifies your MySQL username.

`MYSQL_PWD` (defaults to unset)

This variable specifies your MySQL password.

`MYSQL_TX_ISOLATION_COMPAT` (defaults to `false`)

`POSTGRES_SEEDS` (defaults to unset)

`POSTGRES_USER` (defaults to unset)

This variable specifies your PostgreSQL username.

`POSTGRES_PWD` (defaults to unset)

This variable specifies your PostgreSQL password.

`POSTGRES_TLS_ENABLED` (defaults to `false`)

`POSTGRES_TLS_DISABLE_HOST_VERIFICATION` (defaults to `false`)

`POSTGRES_TLS_CERT_FILE` (defaults to unset)

`POSTGRES_TLS_KEY_FILE` (defaults to unset)

`POSTGRES_TLS_CA_FILE` (defaults to unset)

`POSTGRES_TLS_SERVER_NAME` (defaults to unset)

### Elasticsearch

`ENABLE_ES` (defaults to `false`)

`ES_SCHEME` (defaults to `http`)

`ES_SEEDS` (defaults to unset)

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

`ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS` (defaults to `0`)

### Server setup

`TEMPORAL_ADDRESS` (defaults to unset)

`TEMPORAL_CLI_ADDRESS` (defaults to unset)

This variable is deprecated and support for it will be removed in the future release.

`SKIP_DEFAULT_NAMESPACE_CREATION` (defaults to `false`)

`DEFAULT_NAMESPACE` (defaults to `default`)

`DEFAULT_NAMESPACE_RETENTION` (defaults to `24h`)

`SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES` (defaults to `false`)