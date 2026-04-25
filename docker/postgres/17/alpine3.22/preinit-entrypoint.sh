#!/usr/bin/env bash
set -Eeo pipefail

# 1. Выполняем ваши root-скрипты (могут лежать в образе или монтироваться через volume)
if [ -d /docker-entrypoint-preinit.d ]; then
    for script in /docker-entrypoint-preinit.d/*.sh; do
        [ -x "$script" ] && "$script" || [ -f "$script" ] && bash "$script"
    done
fi

# 2. Передаём управление официальному entrypoint
# Официальный скрипт сам разберётся с gosu, initdb и т.д.
exec /usr/local/bin/docker-entrypoint.sh "$@"
