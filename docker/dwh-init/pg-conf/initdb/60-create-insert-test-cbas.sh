#!/usr/bin/env bash
set -e
set -a; . /docker-entrypoint-initdb.d/.env; set +a


# test_cbas
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER ${CBAS_USERNAME} WITH SUPERUSER CREATEROLE LOGIN PASSWORD '${CBAS_PASSWORD}';
	CREATE DATABASE ${CBAS_DATABASE};
	ALTER DATABASE ${CBAS_DATABASE} OWNER TO ${CBAS_USERNAME};
EOSQL


# 1. Получаем абсолютный путь к папке со скриптами
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
SQL_DIR="${SCRIPT_DIR}/test_cbas"

# 2. Проверяем, существует ли вообще папка, чтобы скрипт не упал
if [ -d "$SQL_DIR" ]; then

    # Изолируем переменные в subshell, чтобы скрыть пароль в процессах
    (
        export PGPASSWORD="${CBAS_PASSWORD}"

        # Цикл по всем файлам с расширением .sql внутри папки
        # Сортировка по имени происходит автоматически в алфавитном порядке
        for sql_file in "${SQL_DIR}"/*.sql; do

            # Проверяем, что это реальный файл, а не пустая маска *.sql
            [ -e "$sql_file" ] || continue

            echo "--- Выполняется скрипт: $(basename "$sql_file") ---"

            psql -v ON_ERROR_STOP=1 \
                 -U "${CBAS_USERNAME}" \
                 -d "${CBAS_DATABASE}" \
                 -f "$sql_file"

            # Если psql завершился с ошибкой, прерываем весь цикл
            if [ $? -ne 0 ]; then
                echo "[ERROR]: Ошибка при выполнении файла $sql_file. Прерывание операции."
                exit 1
            fi
        done
    )

else
    echo "[WARNING]: Директория ${SQL_DIR} не найдена. База test_cbas не инициализирована."
    # exit 1
fi
