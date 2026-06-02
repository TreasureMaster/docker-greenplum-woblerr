#!/bin/bash

# set -a
# . .env
# . .env.projects
# set +a

GITLAB_CONTAINER="${GITLAB_CONTAINER_NAME}"
ROOT_USERNAME="root"
ROOT_PASSWORD="${INITIAL_ROOT_PASSWORD}"
# Костыль: надо добавить в credentials jenkins токен работы с Gitlab
# 1) креды для соединения с api jenkins
JENKINS_INNER_URL="${JENKINS_INNER_URL}"
JENKINS_ADMIN_USER="${START_ADMIN_USERNAME}"
JENKINS_ADMIN_PASSWORD="${START_ADMIN_PASSWORD}"
# 2) для какого пользака (прибито гвоздями, потом выдернуть)
GITLAB_API_USER="${GITLAB_API_USER:-cdjks_user}"
GITLAB_API_TOKEN_NAME="${GITLAB_API_TOKEN_NAME:-airflow-config-update}"
# 3) Проект без .git, для которого нужен токен
GITLAB_API_PROJECT="cfg-airflow"
# 4) ID необходимого проекта (не заполняем, определяется далее в скрипте)
GITLAB_API_PROJECT_ID=""

# Полные пути проектов в GitLab (с .git)
# Пути должны быть аналогичны тому, как они располагаются в gitlab
# Шаблон пути - <group>/<subgroup>/.../<subgroup>/<project-name>.git
# <project-name> должно совпадать с именем архива проекта tar.gz
# PROJECTS=(
#     "Platform/backend/hello-project.git"
#     "Platform/frontend/hello-project.git"
#     "INFRA/hello-world.git"
#     "DWH/ADB/service-projects/automation/jks-test-one.git"
#     "DWH/ADB/service-projects/automation/jks-test-two.git"
# )
declare -A PROJECTS=(
    ["DWH/ADB/service-projects/automation/jks-liquibase-all.git"]=""
    ["DWH/ADB/service-projects/dwh-shared-jenkins.git"]=""
    ["DWH/ADB/service-projects/adb-platform.git"]=""
    ["DWH/ADB/service-projects/help-platform.git"]=""
    ["DWH/ADB/dwh-gp.git"]=""
    ["DWH/ADB/service-projects/adb-internal-config.git"]=""
    ["DWH/ADB/service-projects/automation/jks-automatic-refresh-mv.git"]=""
    ["DWH/ADB/service-projects/automation/jks-multithread-load-hub.git"]=""
    ["DWH/ADB/service-projects/automation/jks-automatic-deploy-help-platform.git"]=""
    ["DWH/ADB/conflog.git"]="prodlog"
    ["DWH/ADB/service-projects/automation/jks-automatic-pxf.git"]=""
    ["DWH/ADB/BASE-CFG/cfg-private.git"]=""
    ["DWH/ADB/service-projects/automation/jks-do-prm-task.git"]=""
    ["DWH/ADB/service-projects/automation/jks_greenplum.git"]=""
    ["DWH/ADB/dwh-service-test.git"]=""
    ["DWH/ADB/BASE-CFG/cfg-schemas.git"]=""
    ["DWH/ADB/service-projects/automation/roles_ddl_repo.git"]=""
    ["DWH/ADB/service-projects/automation/jks-s2t-to-xlsx.git"]=""
    ["DWH/ADB/service-projects/automation/jks-automatic-generate-and-deploy-detail-dags.git"]=""
    ["DWH/ADB/service-projects/airflow_elt.git"]=""
    ["DWH/ADB/service-projects/adb-meta.git"]=""
    ["DWH/ADB/service-projects/automation/jks_airflow.git"]=""
    ["DWH/ADB/service-projects/automation/jks-airflow-params-update.git"]=""
    ["DWH/ADB/BASE-CFG/cfg-airflow.git"]=""
)
# Репозитории, где пользователи добавляются как Maintainer (40)
MAINTAINER_PROJECTS=(
    "conflog"
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
