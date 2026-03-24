#!/bin/bash
# Первичная настройка gitlab - gitlab-init.sh

# set -eu
# set -a; . .env; set +a

echo "Выполняем создание пользователей..."
git_guid=$(docker compose exec ${GITLAB_CONTAINER_NAME} id -g git)
sudo chown -R :${git_guid} ./gitlab-rails-init
docker compose exec ${GITLAB_CONTAINER_NAME} gitlab-rails runner /usr/local/bin/gitlab-rails-init/create-users.rb

# запрет регистрации
echo "Добавляем запрет регистрации"
docker exec ${GITLAB_CONTAINER_NAME} gitlab-rails runner "
  settings = ApplicationSetting.last;
  settings.update!(
    signup_enabled: false,
    can_create_group: false,
    default_project_visibility: 0, # 0 = Private, 10 = Internal, 20 = Public
    default_snippet_visibility: 0,
    default_group_visibility: 0
  )"

echo "Первичная настройка Gitlab завершена."
