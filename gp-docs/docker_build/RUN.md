# Описание запуска докер-контейнера

## Скрипт entrypoint.sh

### Описание env для entrypoint.sh

Большинство переменных первоначально задается в `Dockerfile`.

1. `TZ` - временная зона, по умолчанию `Etc/UTC`.
2. `GREENPLUM_GROUP` - название группы пользователя `${GREENPLUM_USER}`, по умолчанию `gpadmin`.
3. `GREENPLUM_GID` - GID пользователя `${GREENPLUM_USER}`, по умолчанию `1001`.
4. `GREENPLUM_USER` - Имя пользователя, не являющегося root, для выполнения команды (по умолчанию) `gpadmin`.
5. `GREENPLUM_UID` - UID пользователя `${GREENPLUM_USER}`, по умолчанию `1001`.
6. `GREENPLUM_DATA_DIRECTORY` - Расположение каталога данных Greenplum, по умолчанию `/data`.

### Шаги entrypoint.sh

1. `uid` - Определение пользователя, запустившего контейнер
2. Если запущено под `root`
   - если `TZ` отличается от `Etc/UTC`, то происходит установка timezone в `/etc/localtime` и `/etc/timezone`
   - если `GREENPLUM_GROUP` не равна `gpadmin` или `GREENPLUM_GID` не равна 1001, то происходит установка их через `groupmod` для `gpadmin`
   - если `GREENPLUM_USER` не равен `gpadmin` или `GREENPLUM_UID` не равен 1001, то:
     - определяется путь до Java
     - происходит установка их через `usermod` для `gpadmin`
     - выполнение `/usr/local/greenplum-db/greenplum_path.sh` и запись вывода в `.bashrc` (первое формирование этого файла)
     - добавляет `JAVA_HOME` в `.bashrc`
     - добавляет в `PATH` путь `/usr/local/pxf/bin` в `.bashrc`
     - добавляет `PXF_BASE` как `${GREENPLUM_DATA_DIRECTORY}/pxf` в `.bashrc`
     - создание директории с правами 700 `/home/${GREENPLUM_USER}/.ssh`
     - создание директории `/home/${GREENPLUM_USER}/pxf`
     - создание ключа `id_rsa` через `ssh-keygen` для `GREENPLUM_USER`
   - Коррекция прав `GREENPLUM_USER`:`GREENPLUM_GROUP` для `/home/${GREENPLUM_USER}`, `${GREENPLUM_DATA_DIRECTORY}` и `/docker-entrypoint-initdb.d`
3. Если нет `/etc/ssh/ssh_host_rsa_key`, то `ssh-keygen -A` (настройка ssh-сервера, генерация системных ключей, не пользовательских)
4. Создается директория `/run/sshd`
5. Запускается `/usr/sbin/sshd`
6. Ждем 2 секунды
7. Выполнение CMD или command. Если запуск от root, то запуск от имени `GREENPLUM_USER`.

## Скрипт start_gpdb.sh

В скрипте следующие варианты выбора:
1. singlenode
2. master
3. segment

Все остальные варианты будут вызывать ошибку.

Также инициализируются глобальные переменные:
- `gp_init_config_file="${GREENPLUM_DATA_DIRECTORY}/gpinitsystem_config"`
- `gp_init_host_file="${GREENPLUM_DATA_DIRECTORY}/hostfile_gpinitsystem"`
- `gp_custom_init_dir="/docker-entrypoint-initdb.d"`
- `gp_master_dir_name="master"`
- `gp_hostname=$(hostname)`

### Шаги start_gpdb.sh (singlenode)

- `setup_version_config` - инициализирует переменные `gp_major_version`, `gp_log_dir`, `gp_master_data_dir_prefix`
- `verify_prerequisites` - проверяет необходимые для запуска переменные окружения `GREENPLUM_DATA_DIRECTORY`, `GREENPLUM_PASSWORD` и опционально `GREENPLUM_GPMON_PASSWORD`
- `setup_master` - задает переменную master data директории и создает ее
- `setup_segments "00" "primary"` - создает data-директорию сегмента 00/primary
- `setup_segments "01" "primary"` - создает data-директорию сегмента 01/primary
- `setup_gpinitsystem_config`
- `generate_gpinitsystem_config`
- `setup_hostfile_gpinitsystem`
- `generate_hostfile_gpinitsystem`
- `initialize_and_start_gpdb`

### Шаги start_gpdb.sh (master)

- `setup_version_config` - инициализирует переменные `gp_major_version`, `gp_log_dir`, `gp_master_data_dir_prefix`
- `verify_prerequisites`
- `setup_master`
- `setup_gpinitsystem_config`
- `generate_gpinitsystem_config`
- `setup_hostfile_gpinitsystem`
- `initialize_and_start_gpdb`

### Шаги start_gpdb.sh (segment)

- `setup_segment_authorized_keys`
- `initialize_and_start_gpdb_segments "$@"`

### Описание отдельных функций (шагов)

#### setup_version_config

Получает базовый номер версии Greenplum из `gpinitsystem --version` и задает переменные:
- `gp_major_version` - это 6 или 7 версия
- `gp_log_dir` - `pg_log` для 6 или `log` для 7
- `gp_master_data_dir_prefix` - MASTER для 6 или COORDINATOR для 7

#### verify_prerequisites

Проверяет необходимые для запуска данные. Установлены ли некоторые переменные окружения:
  - `file_env` - проверяет наличие переменных `GREENPLUM_PASSWORD` и опционально `GREENPLUM_GPMON_PASSWORD`. Если их нет, устанавливает из secrets docker.
  - `check_required_var` - проверяет, что переменная установлена и не пуста. Для `GREENPLUM_DATA_DIRECTORY`, `GREENPLUM_PASSWORD` и опционально `GREENPLUM_GPMON_PASSWORD`
  - `is_gpperfmon_enabled` - проверяет возможность установки gpperfmon и тогда проводит доп.действия.

#### setup_master

1. export переменной `${gp_master_data_dir_prefix}_DATA_DIRECTORY=${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}/${GREENPLUM_SEG_PREFIX}-1` в `.bashrc`, где:
  - `gp_master_data_dir_prefix` - MASTER или COORDINATOR
  - `gp_master_dir_name` - `master` (задано в скрипте)
  - `GREENPLUM_DATA_DIRECTORY` - задано в dockerfile
  - `GREENPLUM_SEG_PREFIX` - задано в dockerfile
  - Пример: `MASTER_DATA_DIRECTORY=/data/master/gpseg-1`
2. выполняет `.bashrc` для инициализации с новой переменной
3. `create_directory` - создает директорию `${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}` (это, как пример, `/data/master`)

#### setup_segments

1. создает директорию `"${GREENPLUM_DATA_DIRECTORY}/${segment_num}/${segment_type}"`, где
   - `segment_num` - номер сегмента (первый параметр этой функции), например, `00` или `01`
   - `segment_type` - тип сегмента (второй параметр этой функции), например, `primary`
   - Пример: `/data/01/primary`

#### setup_gpinitsystem_config

!!! Прибит гвоздями
1. если есть `/tmp/gpinitsystem_config`, то копирует его в `gp_init_config_file`. Если нет, ничего не делает
   - `gp_init_config_file` - задан глобально в скрипте как `"${GREENPLUM_DATA_DIRECTORY}/gpinitsystem_config"`

#### generate_gpinitsystem_config

1. если на предыдущем этапе не создан `gp_init_config_file`, то он создается по шаблону, по умолчанию

#### setup_hostfile_gpinitsystem

!!! Прибит гвоздями
1. если есть `/tmp/hostfile_gpinitsystem`, то копирует его в `gp_init_host_file`. Если нет, ничего не делает
   - `gp_init_host_file` - задан глобально в скрипте как `"${GREENPLUM_DATA_DIRECTORY}/hostfile_gpinitsystem"`

#### generate_hostfile_gpinitsystem

1. если на предыдущем этапе не создан `gp_init_host_file`, то он создается по глобальной переменной из `$(hostname)`, по умолчанию

#### initialize_and_start_gpdb

Основная многоэтапная функция.

##### Локальные переменные окружения

В самом начале задаются локальные переменные окружения.

- `pg_hba` - путь к `pg_hba.conf` мастера (`${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}/${GREENPLUM_SEG_PREFIX}-1/pg_hba.conf`)
- `pxf_env` - пусть к скрипту `${PXF_BASE}/conf/pxf-env.sh`
- `end_flag` - флаг окончания старта gpdb ??? (по умолчанию пустая строка)
- `gpdb_already_exists_flag` - не выполнять доп.скрипты инициализации, просто флаг наличия `pg_hba.conf` (по умолчанию `false`)

##### Сканирование и добавление ключей хоста

- из `gp_init_host_file` (это глобально `${GREENPLUM_DATA_DIRECTORY}/hostfile_gpinitsystem`) извлекаются по списку все хосты
- с каждого хоста получает публичный ключ и добавляет в список известных хостов `/home/${GREENPLUM_USER}/.ssh/known_hosts`
- права 644 на `/home/${GREENPLUM_USER}/.ssh/known_hosts`

##### Извлечение rsa ssh ключей с хостов

- `ssh-exkeys` по списку `gp_init_host_file` - утилита используется для первоначальной подготовки системы Greenplum Database к доступу по SSH без пароля

##### Старт ранее созданного greenplum, если данные сохранены в volume

- маркер - `gpdb_already_exists_flag=true`
- если pg_hba уже существует, то сохраняется пароль для `gpperfmon` в `.pgpass`
- старт базы `gpstart -a`

##### Старт нового greenplum (первый запуск)

###### Инициализация gpdb

- выполнение `gpinitsystem -e ${GREENPLUM_PASSWORD} -ac ${gp_init_config_file}` (для 6-й версии плюс `--ignore-warnings`)
  - `-e` - передача пароля суперпользователя (gpadmin)
  - `-a` - не запрашивать подтверждение пользователя
  - `-c <gp_init_config_file>` - путь к файлу параметров конфигурации кластера, по умолчанию `${GREENPLUM_DATA_DIRECTORY}/gpinitsystem_config`

###### Установка gpperfmon

Подробно не описываю, т.к. `gpperfmon` не нужен

- Устанавливает для 6-й версии мониторинг `gpperfmon_install` с параметрами:
  - `--enable` - создает и настраивает учетку суперпользователя `gpmon` и устанавливает параметры конфигурации Command Center
  - `--password GREENPLUM_GPMON_PASSWORD` - устанавливает пароль суперпользователя, если был параметр `--enable`
  - `--port 5432` - указывает порт подключения к мастеру (**!!!** прибит гвоздями, исправить)
- Настройка `gpperfmon.conf`
- Настройка TCP в `gpconfig` для docker

###### Настройка diskquota

Расширение `diskquota` у нас установлено, но не включено.
**!!!** Обязательно настроить `psql` с параметром хоста в скрипте, иначе падает с соседней postgres.

- создает базу данных `createdb "diskquota"`