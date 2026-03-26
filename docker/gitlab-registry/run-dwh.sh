#!/bin/bash
# Главный скрипт запуска run-dwh.sh

set -eu
# set -a; . .env; set +a

# if [ "$EUID" -ne 0 ]; then
#     sudo echo "Далее нужны будут права sudo..."
# fi

# Загрузка переменных окружения
. ./gitlabenv.sh

# echo "Запускаем кластер..."
# docker compose up -d


echo "Starting DWH Cluster Initialization..."
echo "   GitLab URL: ${GITLAB_URL}"
echo "   Registry: ${REGISTRY_LOAD_ADDR}"

# ---------------------------------------------------------------------------- #
#                         1. Ждём готовности сервисов                          #
# ---------------------------------------------------------------------------- #
echo "Waiting for GitLab to be ready..."
until curl -sSf "${GITLAB_URL}/users/sign_in" >/dev/null 2>&1; do
    echo "   GitLab not ready, waiting 30s..."
    sleep 30
done
echo "GitLab is ready"

echo "Waiting for Registry to be ready..."
until curl -sSf "http://${REGISTRY_LOAD_ADDR}/v2/" >/dev/null 2>&1; do
    echo "   Registry not ready, waiting 10s..."
    sleep 10
done
echo "Registry is ready"

# ---------------------------------------------------------------------------- #
#                         2. Запускаем инициализацию GitLab                    #
# ---------------------------------------------------------------------------- #
echo ""
echo "=== Running gitlab-init.sh ==="
# /usr/local/bin/gitlab-init.sh

# ---------------------------------------------------------------------------- #
#                         3. Загружаем Docker-образы в registry                #
# ---------------------------------------------------------------------------- #
echo ""
echo "=== Loading Docker images to registry ==="
# Здесь можно вызвать load-images.sh или встроить логику
. ./registry-init.sh

# ---------------------------------------------------------------------------- #
#                         4. Инициализируем репозитории GitLab                 #
# ---------------------------------------------------------------------------- #
echo ""
echo "=== Running repository-init.sh ==="
# /usr/local/bin/repository-init.sh

echo ""
echo "All initialization complete!"



# echo "Ждём, пока GitLab станет healthy..."
# while ! docker compose exec ${GITLAB_CONTAINER_NAME} /opt/gitlab/bin/gitlab-healthcheck >/dev/null 2>&1; do
#   echo "GitLab ещё не готов... ждём 30 секунд"
#   sleep 30
# done


# # Настройка Gitlab
# . ./gitlab-init.sh
# # Инициализация репозиториев Gitlab
# . ./repository-init.sh
