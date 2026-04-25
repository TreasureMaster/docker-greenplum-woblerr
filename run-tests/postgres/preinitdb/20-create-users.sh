#!/usr/bin/env bash

set -euo pipefail
set -a; . /docker-entrypoint-initdb.d/.env; set +a

echo "Running root initialization..."

# Создание пользователя (идемпотентно)
CDJKS_DUMPER_USER="cdjks_dumper"
HOME_DIR="/home/${CDJKS_DUMPER_USER}"

if ! id -u "$CDJKS_DUMPER_USER" &>/dev/null; then
    echo "Creating user: $CDJKS_DUMPER_USER"
    adduser -D -h "$HOME_DIR" -s /bin/bash "$CDJKS_DUMPER_USER"
    echo "$CDJKS_DUMPER_USER:$CDJKS_DUMPER_PASSWORD" | chpasswd

    # Пример: добавление в группу для доступа к общим директориям
    # addgroup "$CDJKS_DUMPER_USER" dockerhost

    echo "User $CDJKS_DUMPER_USER created with home $HOME_DIR"
else
    echo "User $CDJKS_DUMPER_USER already exists, skipping."
fi

# Формируем AllowUsers динамически
# Можно добавить сюда postgres, других сервисных пользователей и т.п.
ALLOWED_USERS="$CDJKS_DUMPER_USER"

# Удаляем старые строки AllowUsers, если были
sed -i '/^AllowUsers/d' /etc/ssh/sshd_config

# Добавляем новую строку AllowUsers
echo "AllowUsers ${ALLOWED_USERS}" >> /etc/ssh/sshd_config

echo "Configured SSH user(s): ${ALLOWED_USERS}"

# Если нужно дать права на выполнение скриптов в конкретной директории:
# TARGET_DIR="/opt/my-scripts"
# [ -d "$TARGET_DIR" ] && chmod -R a+rx "$TARGET_DIR" || true
