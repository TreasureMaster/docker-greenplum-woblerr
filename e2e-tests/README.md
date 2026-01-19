# Сквозное тестирование

Для запуска тестов используется следующая архитектура:

* Отдельные контейнеры с Greenplum (GPDB, Greengage, или WarehousePG).
* Отдельные контейнеры для MinIO и nginx. Используются официальные образы [minio/minio](https://hub.docker.com/r/minio/minio), [minio/mc](https://hub.docker.com/r/minio/mc) и [nginx](https://hub.docker.com/_/nginx). Это необходимо для совместимого с S3 хранилища для архивирования и резервного копирования WAL-файлов.

## Предварительные требования

Перед запуском тестов:

1. Создайте образы Docker для Greenplum, как описано в [Build section](../README.md#build).

2. Настройте тестовую среду, отредактировав файл `e2e-tests/.env`, если это необходимо. (по умолчанию: `GPDB 6.27.1`, другие поддерживаемые: `Greengage`, `WarehousePG`).

3. Подготовьте файлы паролей, как описано в [Prepare section](../README.md#prepare) для Docker Compose. В тестах использовались SSH-ключи из каталога `e2e-tests/conf/ssh/`, поэтому вы можете использовать их или создать свои собственные.

## Запуск тестов

Запуск всех тестов:
```bash
make test-e2e
``` 

### Тесты WAL-G

Основной кластер описан в файле `e2e-tests/docker-compose.gpdb.yml`, резервный кластер — в файле `e2e-tests/docker-compose.gpdb-restore.yml`, а хранилище, совместимое с S3, — в файле `e2e-tests/docker-compose.s3.yml`.

Тест проверяет функциональность резервного копирования и восстановления WAL-G для Greenplum (работает с GPDB и WarehousePG; **не поддерживается для Greengage** из-за изменения типа базы данных):

1. **Полное тестирование резервного копирования**:
   - Создает полную резервную копию на основном кластере
   - Восстанавливает резервную копию на резервном кластере
   - Сравнивает данные между основным и резервным кластерами

2. **Проверка точки восстановления**:
   - Вставляет дополнительные данные в основной кластер
   - Создает точку восстановления
   - Восстанавливает в определенную точку восстановления на резервном кластере
   - Сравнивает данные между кластерами в точке восстановления

Тест проверяет, что данные в таблицах `walg_ao`, `walg_co` и `walg_heap` точно совпадают между основным и резервным кластерами после операций резервного копирования/восстановления.

Запуск:

```bash
make test-e2e-walg
```

или

```bash
cd e2e-tests
make test-e2e-walg
```

или вручную:

```bash
cd [docker-greenplum-root]/e2e-tests
docker compose -f docker-compose.s3.yml -f docker-compose.gpdb.yml -f docker-compose.gpdb-restore.yml up -d
GREENPLUM_PASSWORD=$(cat ../docker-compose/secrets/gpdb_password) ./scripts/e2e-test.sh
docker compose -f docker-compose.s3.yml -f docker-compose.gpdb.yml -f docker-compose.gpdb-restore.yml down
```
