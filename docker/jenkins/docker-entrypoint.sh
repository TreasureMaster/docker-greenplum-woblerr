#!/bin/bash
set -e

# Настройка группы docker
if [ -n "${DOCKER_GID}" ]; then
  if ! getent group docker >/dev/null; then
    groupadd -g "${DOCKER_GID}" docker || true
  else
    groupmod -g "${DOCKER_GID}" docker || true
  fi
  usermod -aG docker jenkins || true
fi

# Права на домашнюю директорию (на всякий случай)
chown -R jenkins:jenkins /var/jenkins_home

# Запуск Jenkins уже от имени jenkins
exec gosu jenkins /usr/bin/tini -- /usr/local/bin/jenkins.sh
