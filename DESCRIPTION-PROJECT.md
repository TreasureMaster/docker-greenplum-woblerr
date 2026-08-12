# Описание проекта регистрации ПО

### Этапы создания проекта

- [x] `greenplum` - запуск greenplum в докере
- [x] `postgres` - запуск и первичная инициализация бд
- [x] `pxf` - подключение pxf к тестовому источнику
- [x] `gitlab` - запуск репозитория кода и его инициализация (тестовые сервисные учетки, проекты)
- [x] `docker-registry` - настройка локального репозитория докер-образов (для liquibase, pg_dump)
- [x] `jenkins` - установка и первоначальная инициализация
- [ ] `jenkins` - настройка работы пайплайнов
- [ ] `airflow` - интеграция airflow

### Требования

- Системные требования (на данном этапе требуется для установки Gitlab):
  - CPU: 8
  - Memory: 16 gb
- В Linux должны быть установлены `docker`, `jq`, `yq`.
- Пользователь, от имени которого запускается стартовый скрипт, должен быть включен в группы `docker` и `sudo`.

### Сборка сервисов

- `docker` - общая папка сборки докер-образов
  - `jenkins` - сборка jenkins
    - `build.sh` - для ленивых
    - `Dockerfile`
    - `plugins.txt` - список требуемых плагинов для предустановки в наш образ (особенно поможет из-за блокировок РКН)

### Запуск сервисов

Примечание: название папок `gitlab4` или `jenkins3` не относится к их версиям. Это просто номера тестовых стендов.
Описание структуры папок и файлов конфигурации:
- `run-tests` - общая папка вариантов конфигов запуска сервисов
  - `gitlab4` - рабочий конфиг запуска gitlab
    - `gitlab-rails-init` - папка настроек системных учетных записей
      - `create-users.rb` - скрипт инициализации системных учетных записей
      - `users.yaml` - список параметров системных учетных записей в формате `yaml`
      - `users.csv` - аналогично, но в формате `csv` (используется, если недоступен `yaml`-файл)
    - `projects` - папка архивов репозиториев кода, которые нужно залить в gitlab
    - `.env` - общие переменные окружения для запуска `docker compose` и скриптов инициализации
    - `.env.projects` - список путей проектов (репозиториев) и соответствующих архивов (можно задать в `gitlabenv.sh`)
    - `docker-compose.yml`
    - `gitlab-init.sh` - добавление учетных записей в gitlab и его первичная настройка
    - `gitlabenv.sh` - переменные для запуска `repository-init.sh`
    - `repository-init.sh` - добавление в gitlab проектов из архивов в папке `projects`, раздача прав для учетных записей
    - `run-dwh.sh` - главный файл запуска сервиса (`docker compose`) и скриптов дальнейшей настройки
  - `jenkins3` - конфиг запуска jenkins
    - `init.groovy.d` - папка стартовых скриптов инициализации jenkins
      - `01-basic-ibit.groovy` - сркипт базовой инициализации jenkins
    - `.env` - переменные окружения для запуска jenkins
    - `docker-compose.yml`
  - `project` - папка текущего проекта
    - `conf` - папка конфигураций greenplum
      - `6` - папка конфига инициализации greenplum
        - `gpinitsystem_config_singlenode` - непосредственно конфиг настроек greenplum
      - `pxf/servers` - настройки pxf для каждого источника
        - `test/jdbc-site.xml` - н-р, для базы test
      - `ssh` - ключи ssh, прокидываемые внутрь (вроде они заменяются реальными, нужно проверять)
      - `hostlist_singlenode` - настройки нод greenplum
    - `pg-conf/initdb` - папка конфигураций postgres
      - `.env.pxf` - настройки инициализации тестовой базы
      - `10-create-conflog-db.sh` - скрипт инициализации тестовой базы
    - `secrets` - папка паролей докера для greenplum и gpperfmon
    - `.env` - переменные для запуска докера
    - `docker-compose.yaml`

### Секреты

Список секретов, используемых в проекте. Их описание и процесс изменения.

##### Администратор Airflow

Название: `AIRFLOW_USERNAME`/`AIRFLOW_PASSWORD` - администратор Airflow
Назначение: используется для доступа к веб-интерфейсу Airflow, а также содания токенов.
Изменение:
- стартовый файл `.env`

##### СУЗ для работы с Airflow из Jenkins

Название: `AIRFLOW_DEPLOY_USERNAME`/`AIRFLOW_DEPLOY_PASSWORD` - jenkins-пользователь в AF
Назначение: выполняет работу с Airflow из Jenkins
Изменение:
- стартовый файл `.env`
- файл `jenkins.yaml`. Нужна пересборка Jenkins (TODO - нужно сделать автоматическое добавление пароля в `jenkins.yaml`).

##### Администратор Jenkins

Название: `START_ADMIN_USERNAME`/`START_ADMIN_PASSWORD` - администратор Jenkins
Назначение: используется для доступа к веб-интерфейсу Jenkins и управления им.
Изменение:
- стартовый файл `.env`
- (опционально). Если креды не заданы или не могут быть прочитаны, то используются креды по умолчанию, заданные в файле `./init.groovy.d/01-basic-init.groovy` для сборки докер-образа `jenkins`. Необходио изменить их тоже и пересобрать образ.

##### СУЗ Jenkins для работы по ssh с greenplum

Название: `JENKINS_SSH_USER`/`JENKINS_SSH_PASS` - ssh-пользователь в Greenplum
Назначение: используется для запуска ansible-ролей на Greenplum из Jenkins.
Изменение:
- стартовый файл `.env`
- файл `jenkins.yaml`. Нужна пересборка Jenkins (TODO - нужно сделать автоматическое добавление пароля в `jenkins.yaml`).
- файл `.env` в `dwh-init/af-conf/preinit/.env`. Необходима пересборка `dwh-init` (TODO - нужно пересмотреть добавление пароля). Этот СУЗ используется для доступа и к Airflow по ssh для выполнения ansible-ролей.

##### Администратор Gitlab

Название: `INITIAL_ROOT_PASSWORD` - пароль администратор Gitlab (пользователь `root` по умолчанию)
Назначение: используется для доступа к веб-интерфейсу Gitlab в роли суперадмина.
Изменение:
- стартовый файл `.env`

##### Redis

Название: `REDIS_PASSWORD` - пароль к Redis
Назначение: используется как очередь задач для Airflow.
Изменение:
- стартовый файл `.env`

##### Conflog

Название: `CONFLOG_PASSWORD` - пароль к БД prodlog
Назначение: используется для метаинформации `help-platform`
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.

##### pg_log (pxf)

Название: `PXF_PASSWORD` - доступ к БД prodlog для pxf-соединения
Назначение: используется для извлечения метаинформации `help-platform` в Greenplum
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.
- файл `docker/dwh-init/pxf/servers/pg_log/jdbc-site.xml`. Для активации необходима пересборка докер-образа `dwh-init`.

##### cdjks_prodlog_deploy

Название: `CDJKS_PRODLOG_DEPLOY_PASSWORD` - доступ к БД prodlog из Jenkins
Назначение: используется для запросов к метаинформации `help-platform` из Jenkins
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.
- файл `jenkins.yaml`. Для активации необходима пересборка докер-образа Jenkins.

##### cdjks_dumper

Название: `CDJKS_DUMPER_PASSWORD` - доступ к БД prodlog из Jenkins
Назначение: используется для формирования бэкапа `prodlog` из Jenkins
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.
- файл `jenkins.yaml`. Для активации необходима пересборка докер-образа Jenkins.

##### svc_dw_kafka_prod

Название: `KAFKA_PASSWORD` - доступ к БД prodlog из Kafka
Назначение: не используется в текущей версии
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.

##### Airflow (postgres meta)

Название: `AFPROD_BASE_PASSWORD/POSTGRESQL_PASSWORD` - доступ к БД метаданных Airflow
Назначение: используется как учетка, формирующая БД метаданных Airflow с последующей работой с этой БД
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.
- стартовый файл `.env` для `docker-compose.yml`.

##### Airflow (postgres prodlog)

Название: `AFPROD_SUZ_PASSWORD` - доступ к БД prodlog из Airflow
Назначение: используется для запросов к метаинформации `prodlog` из Airflow
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.
- файл `jenkins.yaml`. Для активации необходима пересборка докер-образа Jenkins.

##### Тестовые источники данных (pxf)

Название: например, `DS_PASSWORD/CBAS_PASSWORD` - доступ к тестовым БД источников данных
Назначение: используется для pxf-соединения с тестовыми источниками данных из Greenplum
Изменение:
- файл `pg_conf/initdb/.env` в докер-сборке `dwh-init`. Для активации необходима пересборка докер-образа `dwh-init`.
- файл `docker/dwh-init/pxf/servers/test_xxx/jdbc-site.xml`, где `test_xxx` - название соединения. Для активации необходима пересборка докер-образа `dwh-init`.

##### adb_deploy

Название: например, `ADB_DEPLOY_PASSWORD` - доступ к Greenplum из Airflow
Назначение: используется для вспомогательного доступа к Greenplum из Airflow
Изменение:
- стартовый файл `.env`. Требуется перезапуск `docker-compose.yml`.
- файл `jenkins.yaml`. Для активации необходима пересборка докер-образа Jenkins.

##### adb_exec_dwh_small

Название: например, `ADB_EXEC_DWH_PASSWORD` - доступ к Greenplum из Airflow
Назначение: используется для основного доступа к Greenplum из Airflow
Изменение:
- стартовый файл `.env`. Требуется перезапуск `docker-compose.yml`.
- файл `jenkins.yaml`. Для активации необходима пересборка докер-образа Jenkins.

##### adb_exec_dwh_small

Название: например, `ADB_DEPLOY_CDJKS_PASSWORD` - доступ к Greenplum из Jenkins
Назначение: используется для основного доступа к Greenplum из Jenkins
Изменение:
- стартовый файл `.env`. Требуется перезапуск `docker-compose.yml`.
- файл `jenkins.yaml`. Для активации необходима пересборка докер-образа Jenkins.

### ToDo

- [x] объединение сервисов в единый `docker-compose.yml`
- [x] изменение `init-users.sh` на единый скрипт запуска `docker compose` и первоначальной инициализации
- [x] подготовить список системных учетных записей для gitlab
- [x] подготовить архивы проектов для gitlab

### Раскатка меты

1. Gitlab
   - [x] `adb-meta.git`
   - [x] `airflow_elt.git`
   - [ ] `cfg-private.git`
2. Docker repository
   - [x] `ansible:2.11.12`
   - [x] `postgres:15.2`
   - [x] `python:3.10.13`
3. Ansible
   - [ ] Связь с prodlog
   - [ ] Скрипт `get_adb_dump_prod.sh`
4. Пользователи
   - [x] gitlab-пользователь cdjksnd
   - [ ] prodlog-пользователь cdjks_dumper, запуск из ansible
   - [ ] `conflog-prod-admin` в jenkins (`cdjks_prodlog_deploy` на продлоге)