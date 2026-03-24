#!/bin/bash
# Главный скрипт запуска run-dwh.sh

set -eu
set -a; . .env; set +a

if [ "$EUID" -ne 0 ]; then
    sudo echo "Далее нужны будут права sudo..."
fi

# Переменные окружения
SLEEP_TIME="${SLEEP_TIME:-180}"

echo "Запускаем кластер..."
docker compose up -d

echo "Ждём, пока GitLab станет healthy..."
while ! docker compose exec ${GITLAB_CONTAINER_NAME} /opt/gitlab/bin/gitlab-healthcheck >/dev/null 2>&1; do
  echo "GitLab ещё не готов... ждём 30 секунд"
  sleep 30
done


# Настройка Gitlab
. ./gitlab-init.sh
# Инициализация репозиториев Gitlab
. ./repository-init.sh
