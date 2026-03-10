#!/bin/bash

set -e
set -a; . .env; set +a

if [ "$EUID" -ne 0 ]; then
    sudo echo "Далее нужны будут права sudo..."
fi
echo "Запускаем GitLab..."
docker compose up -d
echo "Ждем 3 минуты готовности Gitlab..."
sleep 180

echo "Ждём, пока GitLab станет healthy..."
while ! docker compose exec gitlab /opt/gitlab/bin/gitlab-healthcheck >/dev/null 2>&1; do
  echo "GitLab ещё не готов... ждём 30 секунд"
  sleep 30
done

echo "Выполняем создание пользователей..."
git_guid=$(docker compose exec gitlab id -g git)
sudo chown -R :${git_guid} ./gitlab-rails-init
docker compose exec gitlab gitlab-rails runner /usr/local/bin/gitlab-rails-init/create-users.rb

# запрет регистрации
echo "Добавляем запрет регистрации пользователей"
docker exec gitlab gitlab-rails runner "
  settings = ApplicationSetting.last;
  settings.update!(
    signup_enabled: false,
    can_create_group: false,
    default_project_visibility: 0, # 0 = Private, 10 = Internal, 20 = Public
    default_snippet_visibility: 0,
    default_group_visibility: 0
  )"

echo "Готово!"
