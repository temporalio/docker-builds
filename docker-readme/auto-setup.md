Temporal requires a database backend; this Docker setup script supports Cassandra (default), MySQL, or PostgreSQL.

Optionally also supports Elasticsearch for [visibility](https://docs.temporal.io/self-hosted-guide/visibility).

## Environment Variables

`DB` (default: `cassandra`)

This variable specifies the type of database you're connecting to. Allowed values are `cassandra`, `mysql8`, and `postgres12`.

`SKIP_SCHEMA_SETUP` (default: `false`)

This variable specifies whether database schema creation should be skipped. Set this to true if you're using an existing schema.

`SKIP_DB_CREATE` (default: `false`)

This variable specifies whether database creation should be skipped. Set this to true if you're using an existing database.

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

`CASSANDRA_CERT_KEY` (defaults to unset)

This variable specifies the path to your Cassandra security certificate key, if you are using TLS.

`CASSANDRA_CA` (defaults to unset)

This variable specifies the host of your Cassandra security certificate authority, if needed.

`CASSANDRA_REPLICATION_FACTOR` (defaults to `1`)

This variable specifies [how many replicas](https://docs.apigee.com/private-cloud/v4.17.09/about-cassandra-replication-factor-and-consistency-level) your Cassandra database is using.

### MySQL/PostgreSQL

`DBNAME` (defaults to `temporal`)

This variable specifies the name of your MySQL / Postgres database.

`VISIBILITY_DBNAME` (defaults to `temporal_visibility`)

This variable specifies the name of your MySQL / Postgres visibility database, separate from the main Temporal database.

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

`ES_SCHEMA_SETUP_TIMEOUT_IN_SECONDS` (defaults to `0`)

This variable specifies the Elasticsearch schema setup timeout. The default value of 0 means that schema setup will not time out.

### Server setup

`TEMPORAL_ADDRESS` (defaults to unset)

`SKIP_DEFAULT_NAMESPACE_CREATION` (defaults to `false`)

This variable specifies whether Temporal should skip creating a default namespace on install.

`DEFAULT_NAMESPACE` (defaults to `default`)

This variable specifies the name of the default namespace that your Temporal Service will use.

`DEFAULT_NAMESPACE_RETENTION` (defaults to `24h`)

This variable specifies how long the default namespace will retain data associated with [closed Workflow Executions](https://docs.temporal.io/clusters#retention-period).

`SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES` (defaults to `false`)

This variable specifies whether Temporal should skip adding custom search attributes on install.