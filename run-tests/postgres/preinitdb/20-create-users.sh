#!/usr/bin/env bash

set -euo pipefail

echo "Running root initialization..."

# Создание пользователя (идемпотентно)
USERNAME="cdjks_dumper"
HOME_DIR="/home/${USERNAME}"

if ! id -u "$USERNAME" &>/dev/null; then
    echo "Creating user: $USERNAME"
    adduser -D -h "$HOME_DIR" -s /bin/sh "$USERNAME"

    # Пример: добавление в группу для доступа к общим директориям
    # addgroup "$USERNAME" dockerhost

    echo "User $USERNAME created with home $HOME_DIR"
else
    echo "User $USERNAME already exists, skipping."
fi

# Если нужно дать права на выполнение скриптов в конкретной директории:
# TARGET_DIR="/opt/my-scripts"
# [ -d "$TARGET_DIR" ] && chmod -R a+rx "$TARGET_DIR" || true
