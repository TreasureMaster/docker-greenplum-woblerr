#!/usr/bin/env bash
set -Eeo pipefail

# Пользователь airflow
TARGET_UID="${AIRFLOW_UID:-1001}"
TARGET_GID="${AIRFLOW_GID:-1001}"

mkdir -p /opt/bitnami/airflow/dags/dags
chown -R $TARGET_UID:$TARGET_GID /opt/bitnami/airflow/dags
chmod -R 777 /opt/bitnami/airflow/dags
