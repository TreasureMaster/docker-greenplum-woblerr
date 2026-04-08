#!/usr/bin/env bash
set -e

GREENPLUM_PASSWORD=$(cat "${GP_PASSWORD_FILE}" | tr -d '\n')

PGPASSWORD="$GREENPLUM_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$GREENPLUM_USER" --dbname "$GREENPLUM_DATABASE_NAME" <<-EOSQL
    CREATE ROLE adb_deploys WITH SUPERUSER CREATEROLE;
    CREATE ROLE adb_deploy_cdjks WITH PASSWORD '${ADB_DEPLOY_CDJKS_PASSWORD}';
    GRANT adb_deploys TO adb_deploy_cdjks;
EOSQL

unset GP_PASSWORD_FILE
