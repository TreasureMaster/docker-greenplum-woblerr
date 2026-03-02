#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER usr_prodlog01 WITH PASSWORD 'password111';
	CREATE DATABASE test_log01;
	GRANT ALL PRIVILEGES ON DATABASE test_log01 TO usr_prodlog01;
EOSQL
