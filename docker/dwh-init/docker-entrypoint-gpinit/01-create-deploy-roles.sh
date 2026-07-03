#!/usr/bin/env bash
set -e

GREENPLUM_PASSWORD=$(cat "${GP_PASSWORD_FILE}" | tr -d '\n')

PGPASSWORD="$GREENPLUM_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$GREENPLUM_USER" --dbname "$GREENPLUM_DATABASE_NAME" <<-EOSQL
    CREATE ROLE adb_deploys WITH SUPERUSER CREATEROLE;
    CREATE ROLE adb_deploy_cdjks WITH SUPERUSER CREATEROLE LOGIN PASSWORD '${ADB_DEPLOY_CDJKS_PASSWORD}';
    CREATE ROLE adb_deploy WITH SUPERUSER LOGIN PASSWORD '${ADB_DEPLOY_PASSWORD}';
    GRANT adb_deploys TO adb_deploy_cdjks;
    CREATE ROLE grp_admins;
    CREATE ROLE grp_supports;
    CREATE ROLE adb_exec_dwh;
    CREATE ROLE adb_exec_dwh_small WITH LOGIN PASSWORD '${ADB_EXEC_DWH_PASSWORD}';
    GRANT adb_exec_dwh to adb_exec_dwh_small;
EOSQL

unset GP_PASSWORD_FILE
