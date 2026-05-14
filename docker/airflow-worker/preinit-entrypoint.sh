#!/usr/bin/env bash
set -Eeo pipefail

# 1. Определяем текущий и целевой UID/GID
CURRENT_UID=$(id -u)
# CURRENT_GID=$(id -g)
echo "[preinit] started from current user id: $CURRENT_UID"

# Целевой пользователь: берём из переменных (стандарт Bitnami), fallback на 1001:1001
TARGET_UID="${AIRFLOW_UID:-1001}"
TARGET_GID="${AIRFLOW_GID:-1001}"

# 2. Выполняем ваши root-скрипты (могут лежать в образе или монтироваться через volume)
if [ -d /docker-entrypoint-preinit.d ]; then
    for script in /docker-entrypoint-preinit.d/*.sh; do
        [ -x "$script" ] && "$script" || [ -f "$script" ] && bash "$script"
    done
else
    echo "[preinit] directory '/docker-entrypoint-preinit.d' not exist"
fi

# 3. Запускаем SSH-демон
if command -v sshd >/dev/null 2>&1; then
    # Генерируем host-ключи, если их нет
    # [ ! -f /etc/ssh/ssh_host_rsa_key ] && ssh-keygen -A -t rsa >/dev/null 2>&1
    # [ ! -f /etc/ssh/ssh_host_ecdsa_key ] && ssh-keygen -A -t ecdsa >/dev/null 2>&1

    /usr/sbin/sshd -D &
    echo "[preinit] sshd started in background"
fi

# 4. Исправляем права на каталоги Airflow (важно при монтировании томов от root)
# if [ "$CURRENT_UID" = "0" ]; then
#     echo "[preinit] Fixing ownership for Airflow directories..."
#     chown -R "${TARGET_UID}:${TARGET_GID}" \
#         /opt/bitnami/airflow \
#         /bitnami/airflow \
#         /bitnami/python 2>/dev/null || true
# fi

# 5. Передаём управление официальному entrypoint
# Если запущены от root → используем gosu для переключения на целевого пользователя
# Если уже от non-root → запускаем напрямую
# ls -la /opt/bitnami/scripts/airflow/
# if [ "$CURRENT_UID" = "0" ]; then
#     echo "[preinit] switching to base user"
#     exec gosu "${TARGET_UID}:${TARGET_GID}" /opt/bitnami/scripts/airflow/entrypoint.sh "$@"
# else
#     echo "[preinit] started form base user"
#     exec /opt/bitnami/scripts/airflow/entrypoint.sh "$@"
# fi

exec /opt/bitnami/scripts/${AF_ENTRYPOINT_PATH}/entrypoint.sh "$@"
