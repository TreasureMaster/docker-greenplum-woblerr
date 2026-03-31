#!/bin/bash

# set -a
# . .env
# . .env.projects
# set +a

GITLAB_CONTAINER="${GITLAB_CONTAINER_NAME}"
# GITLAB_URL="http://${GITLAB_HOSTNAME}:${GITLAB_EXTERNAL_PORT}"
# GITLAB_URL="http://${GITLAB_HOSTNAME}:${GITLAB_PORT}"
ROOT_USERNAME="root"
ROOT_PASSWORD="${INITIAL_ROOT_PASSWORD}"

# REGISTRY_LOAD_ADDR="${REGISTRY_HOSTNAME}"
# REGISTRY_LOAD_ADDR="${REGISTRY_HOSTNAME}:${REGISTRY_PORT}"

# Полные пути проектов в GitLab (с .git)
# Пути должны быть аналогичны тому, как они располагаются в gitlab
# Шаблон пути - <group>/<subgroup>/.../<subgroup>/<project-name>.git
# <project-name> должно совпадать с именем архива проекта tar.gz
PROJECTS=(
    "Platform/backend/hello-project.git"
    "Platform/frontend/hello-project.git"
    "INFRA/hello-world.git"
    "DWH/ADB/service-projects/automation/jks-test-one.git"
    "DWH/ADB/service-projects/automation/jks-test-two.git"
)

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
