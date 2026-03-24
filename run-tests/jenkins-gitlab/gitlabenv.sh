#!/bin/bash

set -a
. .env
. .env.projects
set +a

GITLAB_CONTAINER="${GITLAB_CONTAINER_NAME}"
GITLAB_HOST="${GITLAB_HOSTNAME}"
GITLAB_URL="http://${GITLAB_HOST}:${GITLAB_EXTERNAL_PORT}"
ROOT_USERNAME="root"


# Архивы ищем в ./projects/<project-name>.tar.gz
ARCHIVE_DIR="./projects"

# Список пользователей
USERS_YAML="./gitlab-rails-init/users.yaml"
USERS_CSV="./gitlab-rails-init/users.csv"

if [[ -f "${USERS_YAML}" ]]; then
  USERS_SOURCE="yaml"
  echo "Использую пользователей из ${USERS_YAML}"
elif [[ -f "${USERS_CSV}" ]]; then
  USERS_SOURCE="csv"
  echo "Использую пользователей из ${USERS_CSV}"
else
  USERS_SOURCE=""
  echo "WARNING: users.yml и users.csv не найдены, добавление пользователей в группы отключено" >&2
fi
