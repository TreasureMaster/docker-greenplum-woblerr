# docker-greenplum

[![build-gpdb6](https://github.com/woblerr/docker-greenplum/actions/workflows/build-gpdb6.yml/badge.svg)](https://github.com/woblerr/docker-greenplum/actions/workflows/build-gpdb6.yml)
[![build-gpdb7](https://github.com/woblerr/docker-greenplum/actions/workflows/build-gpdb7.yml/badge.svg)](https://github.com/woblerr/docker-greenplum/actions/workflows/build-gpdb7.yml)
[![build-greengage6](https://github.com/woblerr/docker-greenplum/actions/workflows/build-greengage6.yml/badge.svg)](https://github.com/woblerr/docker-greenplum/actions/workflows/build-greengage6.yml)
[![build-greengage7](https://github.com/woblerr/docker-greenplum/actions/workflows/build-greengage7.yml/badge.svg)](https://github.com/woblerr/docker-greenplum/actions/workflows/build-greengage7.yml)
[![build-warehousepg6](https://github.com/woblerr/docker-greenplum/actions/workflows/build-warehousepg6.yml/badge.svg)](https://github.com/woblerr/docker-greenplum/actions/workflows/build-warehousepg6.yml)

Этот проект предоставляет образы Docker для запуска базы данных Greenplum (GPDB) и её форков в контейнерах. Он поддерживает как одноузловые, так и многоузловые развертывания. Образы могут использоваться для разработки, тестирования и обучения.

**Поддерживаемые дистрибутивы:**
- Greenplum Database (GPDB)
- [Greengage](https://github.com/GreengageDB/greengage) (GGDB)
- [WarehousePG](https://github.com/warehouse-pg/warehouse-pg) (WHPG)

В Docker Greenplum предоставляет следующие возможности:
- развертывание на одном узле;
- развертывание основного блока и сегментов;
- поддержка зеркального отображения сегментов;
- gpperfmon (только для GPDB 6);
- diskquota;
- gpbackup/gprestore;
- gpbackup-s3-plugin;
- gpbackman;
- PXF (Platform Extension Framework);
- пользовательские скрипты инициализации;
- WAL-G (физические резервные копии).

Переменные среды, поддерживаемые этим образом:

* `TZ` - Часовой пояс контейнера, по умолчанию `Etc/UTC`;
* `GREENPLUM_USER` - Имя пользователя, не являющегося root, для выполнения команды (по умолчанию) `gpadmin`;
* `GREENPLUM_UID` - UID пользователя `${GREENPLUM_USER}`, по умолчанию `1001`;
* `GREENPLUM_GROUP` - название группы пользователя `${GREENPLUM_USER}`, по умолчанию `gpadmin`;
* `GREENPLUM_GID` - GID пользователя `${GREENPLUM_USER}`, по умолчанию `1001`;
* `GREENPLUM_DEPLOYMENT` - Тип развертывания Greenplum, по умолчанию `singlenode`, доступные значения: `singlenode`, `master`, `segment`;
* `GREENPLUM_DATA_DIRECTORY` - Расположение каталога данных Greenplum, по умолчанию `/data`;
* `GREENPLUM_SEG_PREFIX` - префикс сегмента Greenplum, по умолчанию `gpseg`;
* `GREENPLUM_DATABASE_NAME` - Название базы данных Greenplum, по умолчанию `demo`, this database will be created during the initialization;
* `GREENPLUM_GPPERFMON_ENABLE` - включить gpperfmon (только для GPDB 6), по умолчанию `false`;
* `GREENPLUM_DISKQUOTA_ENABLE` - включить diskquota, по умолчанию `false`;
* `GREENPLUM_PXF_ENABLE` - включить PXF, по умолчанию `false`;
* `GREENPLUM_WALG_ENABLE` - включить WAL-G, по умолчанию `false`;

Необходимые переменные среды:
* `GREENPLUM_PASSWORD` - пароль для пользователя `${GREENPLUM_USER}`, **required**;
* `GREENPLUM_GPMON_PASSWORD` - пароль для пользователя `gpmon`, **required** когда `GREENPLUM_GPPERFMON_ENABLE` равно `true`;

## Матрица сборки

В репозитории содержится информация о последних доступных версиях.
Для конкретной версии вы можете создать собственный образ, используя соответствующий раздел [Build](#build).

Greenplum 6:
| GPDB Version | Ubuntu 22.04                   | Oracle Linux 8        | Platform                     |
| ------------ | ------------------------------ | --------------------- | ---------------------------- |
| 6.27.1       | `6.27.1`, `6.27.1-ubuntu22.04` | `6.27.1-oraclelinux8` | `linux/amd64`, `linux/arm64` |

Greenplum 7:
| GPDB Version | Ubuntu 22.04                 | Oracle Linux 8       | Platform                     |
| ------------ | ---------------------------- | -------------------- | ---------------------------- |
| 7.1.0        | `7.1.0`, `7.1.0-ubuntu22.04` | `7.1.0-oraclelinux8` | `linux/amd64`, `linux/arm64` |

Greengage 6:
| Greengage Version | Ubuntu 22.04                   | Oracle Linux 8        | Platform                     |
| ----------------- | ------------------------------ | --------------------- | ---------------------------- |
| 6.29.2            | `6.29.2`, `6.29.2-ubuntu22.04` | `6.29.2-oraclelinux8` | `linux/amd64`, `linux/arm64` |

Greengage 7:
| Greengage Version | Ubuntu 22.04                 | Oracle Linux 8       | Platform                     |
| ----------------- | ---------------------------- | -------------------- | ---------------------------- |
| 7.4.1             | `7.4.1`, `7.4.1-ubuntu22.04` | `7.4.1-oraclelinux8` | `linux/amd64`, `linux/arm64` |

WarehousePG 6:
| WarehousePG Version | Ubuntu 22.04                             | Oracle Linux 8             | Platform                     |
| ------------------- | ---------------------------------------- | -------------------------- | ---------------------------- |
| 6.27.2-WHPG         | `6.27.2-WHPG`, `6.27.2-WHPG-ubuntu22.04` | `6.27.2-WHPG-oraclelinux8` | `linux/amd64`, `linux/arm64` |

## Загрузка
Замените `tag` на нужную вам версию.

**Greenplum:**

* Docker Hub:

```bash
docker pull woblerr/greenplum:tag
```

* GitHub Registry:

```bash
docker pull ghcr.io/woblerr/greenplum:tag
```

**Greengage:**

* Docker Hub:

```bash
docker pull woblerr/greengage:tag
```

* GitHub Registry:

```bash
docker pull ghcr.io/woblerr/greengage:tag
```

**WarehousePG:**

* Docker Hub:

```bash
docker pull woblerr/warehousepg:tag
```

* GitHub Registry:

```bash
docker pull ghcr.io/woblerr/warehousepg:tag
```

## Запуск

Вам потребуется смонтировать необходимые каталоги или файлы внутри контейнера (или использовать этот образ для создания собственного на его основе).

### Простой запуск

```bash
docker run -p 5432:5432 -e GREENPLUM_PASSWORD=gparray -d greenplum:6.27.1
```

Подключение к Greenplum:

```bash
psql -h localhost -p 5432 -U gpadmin demo
```

### Секреты Docker
В качестве альтернативы передаче конфиденциальной информации через переменные окружения, к переменным окружения `GREENPLUM_PASSWORD` и `GREENPLUM_GPMON_PASSWORD` можно добавить `_FILE`. В частности, это можно использовать для загрузки паролей из секретов Docker, хранящихся в файлах `/run/secrets/<secret_name>`.

Например:
```bash
docker run -p 5432:5432 -e GREENPLUM_PASSWORD_FILE=/run/secrets/gpdb_password -d greenplum:6.27.1
```

### Скрипты инициализации

Образ поддерживает запуск пользовательских скриптов инициализации `*.sql` или `*.sh` после запуска Greenplum. Разместите свои скрипты в каталоге `/docker-entrypoint-initdb.d` внутри контейнера.

Скрипты в `/docker-entrypoint-initdb.d` выполняются только в том случае, если контейнер запускается с пустым каталогом данных; любая существующая база данных останется нетронутой при запуске контейнера.

#### Процесс выполнения скрипта

Обработка скриптов осуществляется следующим образом:
- **SQL-скрипты** (`*.sql`): Выполняется с помощью `psql` со следующими параметрами:
  - Выполняется для базы данных, указанной в `GREENPLUM_DATABASE_NAME`.
  - Запуск с флагом `-v ON_ERROR_STOP=1`.
  - Запуск с `--no-psqlrc`.
  - Подключение как `GREENPLUM_USER`.
- **Shell-скрипты** (`*.sh`):
  - Если скрипт имеет права на выполнение, он запускается напрямую.
  - Если файл не является исполняемым, он загружается из репозитория.
- **Другие файлы**: Файлы с другими расширениями игнорируются.

Пример скрипта инициализации SQL `00_init.sql`:

```sql
CREATE TABLE test_initialization (
  id serial PRIMARY KEY,
  name text,
  created_at timestamp DEFAULT current_timestamp
);

INSERT INTO test_initialization (name) VALUES ('Initialized via sql script');
```
Пример скрипта shell `01_init.sh`:

```bash
#!/bin/bash
echo "Executing initialization shell script"
psql -U ${GREENPLUM_USER} -h $(hostname) -d ${GREENPLUM_DATABASE_NAME} -c "INSERT INTO test_initialization (name) VALUES ('Added via shell script');"
echo "Shell script executed successfully!"
```

Вы можете смонтировать каталог со скриптами инициализации в контейнер:

```bash
docker run -p 5432:5432 \
  -e GREENPLUM_PASSWORD=gparray \
  -v $(pwd)/docs/custom_init_scripts:/docker-entrypoint-initdb.d \
  -d greenplum:6.27.1
```

Или создайте собственный образ:

```bash
FROM greenplum:6.27.1
COPY docs/custom_init_scripts/* /docker-entrypoint-initdb.d/
```

#### Настройка WAL-G

Если `GREENPLUM_WALG_ENABLE=true`, WAL-G устанавливается и становится доступен, но его необходимо настроить вручную или использовать скрипты инициализации для установки `archive_command` и других параметров.


```bash
docker run -p 5432:5432 \
  -e GREENPLUM_PASSWORD=gparray \
  -e GREENPLUM_WALG_ENABLE=true \
  -v $(pwd)/wal-g.yaml:/tmp/wal-g.yaml \
  -v $(pwd)/wal-g_init.sh:/docker-entrypoint-initdb.d/wal-g_init.sh \
  -d greenplum:6.27.1
```

Как лучше разместить скрипты инициализации для WAL-G:
```bash
#!/bin/bash
echo "Configuring wal-g archive_command"
USER=${GREENPLUM_USER} gpconfig -c archive_command -v "wal-g seg wal-push %p --content-id=%c --config /tmp/wal-g.yaml"
USER=${GREENPLUM_USER} gpconfig -c archive_timeout -v 600 --skipvalidation
USER=${GREENPLUM_USER} gpstop -u
```

### Docker Compose
#### Подготовка

Подготовьте файлы паролей (**установите собственные пароли**):
```bash
echo "gparray" > docker-compose/secrets/gpdb_password
echo "changeme" > docker-compose/secrets/gpmon_password
```

Для корректного запуска docker compose необходимо смонтировать конфигурационные файлы в каталог `/tmp`.
Это действительно для файлов `gpinitsystem_config`, `hostfile_gpinitsystem` и `authorized_keys`.

Ключи SSH RSA должны быть смонтированы в директорию `/home/${GREENPLUM_USER}/.ssh/`.
Монтирование master:
```yaml
    volumes:
      - ./conf/${CONFIG_FOLDER}/gpinitsystem_config_no_mirrors:/tmp/gpinitsystem_config
      - ./conf/hostfile_gpinitsystem:/tmp/hostfile_gpinitsystem
      - ./conf/ssh/id_rsa:/home/gpadmin/.ssh/id_rsa
      - ./conf/ssh/id_rsa.pub:/home/gpadmin/.ssh/id_rsa.pub
```
Монтирование сегментов:
```yaml
    volumes:
       - ./conf/ssh/authorized_keys:/tmp/authorized_keys
```

Имя образа, версия и переменная `CONFIG_FOLDER` должны быть заданы в файле `.env`. Пример файла `.env` можно найти в каталоге `docker-compose`.

#### Запуск
Запуск кластера с 1 мастером и 2 сегментами без зеркалирования.:
```bash
docker compose -f ./docker-compose/docker-compose.no_mirrors.yaml up -d
```

Запуск кластера с постоянным хранилищем:
```bash
docker compose -f ./docker-compose/docker-compose.no_mirrors_persistent.yaml up -d
```

Запуск кластера с 1 главным сервером и 2 сегментами с зеркалированием:
```bash
docker compose -f ./docker-compose/docker-compose.with_mirrors.yaml up -d
```

## Сборка

**Greenplum:**

Для образов на основе Ubuntu:
```bash
make build_gpdb_6_ubuntu TAG_GPDB_6=6.27.1
```
```bash
make build_gpdb_7_ubuntu TAG_GPDB_7=7.1.0
```

Для образов на базе Oracle Linux:
```bash
make build_gpdb_6_oraclelinux TAG_GPDB_6=6.27.1
```
```bash
make build_gpdb_7_oraclelinux TAG_GPDB_7=7.1.0
```

**Greengage:**

Для образов на основе Ubuntu:
```bash
make build_greengage_6_ubuntu TAG_GREENGAGE_6=6.29.2
```
```bash
make build_greengage_7_ubuntu TAG_GREENGAGE_7=7.4.1
```

Для образов на базе Oracle Linux:
```bash
make build_greengage_6_oraclelinux TAG_GREENGAGE_6=6.29.2
```
```bash
make build_greengage_7_oraclelinux TAG_GREENGAGE_7=7.4.1
```

**WarehousePG:**

Для образов на основе Ubuntu:
```bash
make build_warehousepg_6_ubuntu TAG_WAREHOUSEPG_6=6.27.2-WHPG
```

Для образов на базе Oracle Linux:
```bash
make build_warehousepg_6_oraclelinux TAG_WAREHOUSEPG_6=6.27.2-WHPG
```

**Примеры ручной сборки:**

Greenplum с простой ручной сборкой:
```bash
docker buildx build -f docker/greenplum/ubuntu22.04/6/Dockerfile -t greenplum:6.27.1 .
```

Greengage с простой ручной сборкой:
```bash
docker buildx build -f docker/greengage/ubuntu22.04/6/Dockerfile -t greengage:6.29.2 .
```
```bash
docker buildx build -f docker/greengage/ubuntu22.04/7/Dockerfile -t greengage:7.4.1 .
```

Greengage OracleLinux (ручная сборка):
```bash
docker buildx build -f docker/greengage/oraclelinux8/6/Dockerfile -t greengage:6.29.2-oraclelinux8 .
```
```bash
docker buildx build -f docker/greengage/oraclelinux8/7/Dockerfile -t greengage:7.4.1-oraclelinux8 .
```

WarehousePG (простая ручная сборка):
```bash
docker buildx build -f docker/warehousepg/ubuntu22.04/6/Dockerfile -t warehousepg:6.27.2-WHPG .
```

WarehousePG OracleLinux (ручная сборка):
```bash
docker buildx build -f docker/warehousepg/oraclelinux8/6/Dockerfile -t warehousepg:6.27.2-WHPG-oraclelinux8 .
```

Ручная сборка с указанием конкретной версии компонента для платформы `linux/amd64`:
```bash
docker buildx build --platform linux/amd64 -f docker/greenplum/ubuntu22.04/6/Dockerfile --build-arg GPDB_VERSION=6.27.1 -t greenplum:6.27.1 .
```

Ручная сборка с указанием конкретных версий компонентов для платформ `linux/amd64` и `linux/arm64`.:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -f docker/greenplum/ubuntu22.04/6/Dockerfile --build-arg GPDB_VERSION=6.27.1 --build-arg DISKQUOTA_VERSION=2.3.0 --build-arg GPBACKUP_VERSION=1.30.5 -t greenplum:6.27.1 .
```

## Запуск тестов
Запуск сквозного тестирования:
```bash
make test-e2e
```
See [tests description](./e2e-tests/README.md).
