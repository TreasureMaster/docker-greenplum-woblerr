#!/bin/bash

set -a; . .env; set +a

GITLAB_CONTAINER="${GITLAB_CONTAINER_NAME}"
GITLAB_HOST="${GITLAB_HOSTNAME}"
GITLAB_URL="http://${GITLAB_HOST}:8080"
ROOT_USERNAME="root"

# Полные пути проектов в GitLab (с .git)
# Пути должны быть аналогичны тому, как они располагаются в gitlab
# Шаблон пути - <group>/<subgroup>/.../<subgroup>/<project-name>.git
# <project-name> должно совпадать с именем архива проекта tar.gz
PROJECTS=(
    "Platform/backend/hello-project.git"
    "Platform/frontend/hello-project.git"
    "INFRA/hello-world.git"
)

# Архивы ищем в ./projects/<project-name>.tar.gz
ARCHIVE_DIR="./projects"
