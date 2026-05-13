#!/bin/bash
set -euo pipefail
set -a; . /docker-entrypoint-preinit.d/.env; set +a

# Параметры (можно передавать как аргументы или использовать значения по умолчанию)
# ADPROD_DEPLOY_USER="${1:-deployer}"
TARGET_DIR=/opt/bitnami/airflow/dags

# Создать пользователя, если не существует
if ! id "$ADPROD_DEPLOY_USER" &>/dev/null; then
    echo "[ERROR]: Пользователь $ADPROD_DEPLOY_USER предварительно должен быть создан"
    exit 1
    # useradd -m -s /bin/bash "$ADPROD_DEPLOY_USER"
fi

# Убедиться, что целевая директория существует
mkdir -p "$TARGET_DIR"

# Добавить пользователя в группу sudo (если нужно полное sudo)
usermod -aG sudo "$ADPROD_DEPLOY_USER"

# Создать файл sudoers с точечными правами
SUDOERS_FILE="/etc/sudoers.d/${ADPROD_DEPLOY_USER}"

cat > "$SUDOERS_FILE" << EOF
# Права для пользователя $ADPROD_DEPLOY_USER на деплой Airflow DAGs
# Сгенерировано автоматически: $(date)

# Разрешить создание директорий в целевой папке
Cmnd_Alias MKDIR_DAGS = /bin/mkdir -p ${TARGET_DIR}/*
Cmnd_Alias CHMOD_DAGS = /bin/chmod *[0-7][0-7][0-7] ${TARGET_DIR}/*

# Разрешить rsync для синхронизации файлов
Cmnd_Alias RSYNC_DAGS = /usr/bin/rsync --server *

${ADPROD_DEPLOY_USER} ALL = NOPASSWD: MKDIR_DAGS, CHMOD_DAGS, RSYNC_DAGS

# Опционально: разрешить chown/chgrp если нужно
# ${ADPROD_DEPLOY_USER} ALL = NOPASSWD: /bin/chown ${ADPROD_DEPLOY_USER}:${ADPROD_DEPLOY_USER} ${TARGET_DIR}/*
# ${ADPROD_DEPLOY_USER} ALL = NOPASSWD: /bin/chgrp ${ADPROD_DEPLOY_USER} ${TARGET_DIR}/*
EOF

# Установить правильные права на файл sudoers (обязательно!)
chmod 440 "$SUDOERS_FILE"
chown root:root "$SUDOERS_FILE"

# Проверить синтаксис sudoers
if command -v visudo &>/dev/null; then
    if ! visudo -cf "$SUDOERS_FILE"; then
        echo "[ERROR]: файл sudoers имеет неверный синтаксис!" >&2
        exit 1
    fi
    echo "Файл sudoers успешно проверен"
else
    echo "[WARNING]: visudo не найден, пропускаем проверку синтаксиса"
fi

echo "Права sudo для пользователя '$ADPROD_DEPLOY_USER' успешно настроены"
echo "Целевая директория: $TARGET_DIR"
echo "Файл конфигурации: $SUDOERS_FILE"
