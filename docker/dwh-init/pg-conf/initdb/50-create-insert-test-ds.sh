#!/usr/bin/env bash
set -e
set -a; . /docker-entrypoint-initdb.d/.env; set +a

# Получаем абсолютный путь к папке, где лежит сам bash-скрипт
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# test_ds
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER ${DS_USERNAME} WITH SUPERUSER CREATEROLE LOGIN PASSWORD '${DS_PASSWORD}';
	CREATE DATABASE ${DS_DATABASE};
	ALTER DATABASE ${DS_DATABASE} OWNER TO ${DS_USERNAME};
EOSQL

# PGPASSWORD=${DS_PASSWORD} psql -v ON_ERROR_STOP=1 \
#      -U "${DS_USERNAME}" \
#      -d "${DS_DATABASE}" \
#      -f "${SCRIPT_DIR}/test_ds/dbo.tCountry.sql"

# (
#   export PGPASSWORD="${DS_PASSWORD}"
#   psql -v ON_ERROR_STOP=1 \
#        -U "${DS_USERNAME}" \
#        -d "${DS_DATABASE}" \
#        -f "${SCRIPT_DIR}/test_ds/dbo.tCountry.sql"
# )

# 1. Получаем абсолютный путь к папке со скриптами
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
SQL_DIR="${SCRIPT_DIR}/test_ds"

# 2. Проверяем, существует ли вообще папка, чтобы скрипт не упал
if [ -d "$SQL_DIR" ]; then

    # Изолируем переменные в subshell, чтобы скрыть пароль в процессах
    (
        export PGPASSWORD="${DS_PASSWORD}"

        # Цикл по всем файлам с расширением .sql внутри папки
        # Сортировка по имени происходит автоматически в алфавитном порядке
        for sql_file in "${SQL_DIR}"/*.sql; do

            # Проверяем, что это реальный файл, а не пустая маска *.sql
            [ -e "$sql_file" ] || continue

            echo "--- Выполняется скрипт: $(basename "$sql_file") ---"

            psql -v ON_ERROR_STOP=1 \
                 -U "${DS_USERNAME}" \
                 -d "${DS_DATABASE}" \
                 -f "$sql_file"

            # Если psql завершился с ошибкой, прерываем весь цикл
            if [ $? -ne 0 ]; then
                echo "[ERROR]: Ошибка при выполнении файла $sql_file. Прерывание операции."
                exit 1
            fi
        done
    )

else
    echo "[WARNING]: Директория ${SQL_DIR} не найдена. База test_ds не инициализирована."
    exit 1
fi
