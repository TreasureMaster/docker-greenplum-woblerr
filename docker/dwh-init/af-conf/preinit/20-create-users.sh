#!/usr/bin/env bash

set -euo pipefail
set -a; . /docker-entrypoint-preinit.d/.env; set +a

echo "Running root initialization..."

# Создание пользователя (идемпотентно)
# ADPROD_DEPLOY_USER="svc_cdjks_adprod"
HOME_DIR="/home/${ADPROD_DEPLOY_USER}"

if ! id -u "$ADPROD_DEPLOY_USER" &>/dev/null; then
    echo "Creating user: $ADPROD_DEPLOY_USER"
    # NOTE переход с alpine на debian
    # adduser -D -h "$HOME_DIR" -s /bin/bash "$ADPROD_DEPLOY_USER"
    useradd -m -d "$HOME_DIR" -s /bin/bash "$ADPROD_DEPLOY_USER"
    echo "$ADPROD_DEPLOY_USER:$ADPROD_DEPLOY_PASSWORD" | chpasswd

    echo "User $ADPROD_DEPLOY_USER created with home $HOME_DIR"
else
    echo "User $ADPROD_DEPLOY_USER already exists, skipping."
fi

# Формируем AllowUsers динамически
# Можно добавить сюда postgres, других сервисных пользователей и т.п.
ALLOWED_USERS="$ADPROD_DEPLOY_USER"

# Удаляем старые строки AllowUsers, если были
sed -i '/^AllowUsers/d' /etc/ssh/sshd_config

# Добавляем новую строку AllowUsers
echo "AllowUsers ${ALLOWED_USERS}" >> /etc/ssh/sshd_config

echo "Configured SSH user(s): ${ALLOWED_USERS}"

# Если нужно дать права на выполнение скриптов в конкретной директории:
# TARGET_DIR="/opt/my-scripts"
# [ -d "$TARGET_DIR" ] && chmod -R a+rx "$TARGET_DIR" || true
