#!/usr/bin/env bash
set -e
set -a; . /docker-entrypoint-initdb.d/.env; set +a

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER ${AFPROD_BASE_USERNAME} WITH PASSWORD '${AFPROD_BASE_PASSWORD}';
	CREATE DATABASE ${AFPROD_BASE_DB};
	GRANT ALL PRIVILEGES ON DATABASE ${AFPROD_BASE_DB} TO ${AFPROD_BASE_USERNAME};
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER ${CONFLOG_USERNAME} WITH PASSWORD '${CONFLOG_PASSWORD}';
	CREATE DATABASE ${CONFLOG_DATABASE};
	GRANT ALL PRIVILEGES ON DATABASE ${CONFLOG_DATABASE} TO ${CONFLOG_USERNAME};
	CREATE ROLE rl_reader;
	CREATE ROLE rl_owner_db;
	CREATE ROLE rl_lm_worker;
	CREATE ROLE rl_log_worker;
	CREATE ROLE cdjks_prodlog_deploy WITH PASSWORD '${CDJKS_PRODLOG_DEPLOY_PASSWORD}';
	CREATE ROLE cdjks_dumper WITH PASSWORD '${CDJKS_DUMPER_PASSWORD}'
	CREATE ROLE afprod WITH PASSWORD '${AFPROD_PASSWORD}';
EOSQL

PGPASSWORD="$CONFLOG_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$CONFLOG_USERNAME" --dbname "$CONFLOG_DATABASE" <<-EOSQL
	GRANT CREATE ON DATABASE db_prod_log01 TO rl_owner_db;
	GRANT CONNECT ON DATABASE db_prod_log01 TO rl_owner_db;
	GRANT db_prod_log01 TO rl_owner_db;

	GRANT rl_owner_db TO cdjks_prodlog_deploy;
	GRANT rl_reader	TO cdjks_prodlog_deploy;
	GRANT rl_lm_worker TO cdjks_prodlog_deploy;
	GRANT rl_log_worker	TO cdjks_prodlog_deploy;

	GRANT rl_reader	TO cdjks_dumper;

	GRANT rl_lm_worker TO afprod;
	GRANT rl_log_worker	TO afprod;

	CREATE SCHEMA adb AUTHORIZATION rl_owner_db;
	GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA adb TO rl_owner_db;
	CREATE SCHEMA liquibase AUTHORIZATION rl_owner_db;
EOSQL
