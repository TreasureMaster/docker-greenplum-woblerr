#!/usr/bin/env bash
set -Eeuo pipefail

# Load libraries
. /liblog.sh
. /libenv.sh

gp_init_config_file="${GREENPLUM_DATA_DIRECTORY}/gpinitsystem_config"
gp_init_host_file="${GREENPLUM_DATA_DIRECTORY}/hostfile_gpinitsystem"
gp_custom_init_dir="/docker-entrypoint-initdb.d"
gp_master_dir_name="master"
gp_hostname=$(hostname)


# Применение: file_env VAR [DEFAULT]
# Например  : file_env 'XYZ_DB_PASSWORD' 'example'
# (это позволит использовать переменную "$XYZ_DB_PASSWORD_FILE"
# для заполнения значения "$XYZ_DB_PASSWORD" из файла,
# особенно с учетом возможностей Docker по работе с секретами)
file_env() {
    local var="$1"
    debug "Variable ${var} initializing from file env..."
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        error_and_exit "Both $var and $fileVar are set (but are exclusive)"
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi

    export "$var"="$val"
    unset "$fileVar"
}

setup_version_config() {
    debug "Setup version config"
    source "/home/${GREENPLUM_USER}/.bashrc"
    # Получить основную версию gpdb с помощью команды gpinitsystem.
    # Необходимо знать версию, чтобы работать с правильными каталогами.
    # Пример: gpinitsystem 6.26.4 build dev
    gp_major_version=$(gpinitsystem --version | cut -d' ' -f2 | cut -d'.' -f1)
    case ${gp_major_version} in
      "6")
        gp_log_dir="pg_log"
        gp_master_data_dir_prefix="MASTER"
        ;;
      "7")
        gp_log_dir="log"
        gp_master_data_dir_prefix="COORDINATOR"
        ;;
      *)
        error_and_exit "Invalid Greenplum version: ${gp_major_version}"
        ;;
    esac
}

create_directory() {
    local dir=$1
    if [ ! -d "${dir}" ]; then
        echo "INFO - Creating directory: ${dir}"
        mkdir -p "${dir}"
    fi
}

setup_master() {
    debug "Setup master"
    echo "export ${gp_master_data_dir_prefix}_DATA_DIRECTORY=${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}/${GREENPLUM_SEG_PREFIX}-1" >> ~/.bashrc
    source "/home/${GREENPLUM_USER}/.bashrc"
    create_directory "${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}"
}

setup_segments() {
    debug "Setup segment $1"
    local segment_num=$1
    local segment_type=$2
    create_directory "${GREENPLUM_DATA_DIRECTORY}/${segment_num}/${segment_type}"
}

# Устранение проблемы с GPDB 7 при использовании смонтированного файла authorized_keys в Docker.
# В GPDB 7 команда gpssh-exkeys использует rsync для копирования authorized_keys,
# и в результате возникает ошибка:
#   rsync: rename "/home/gpadmin/.ssh/.authorized_keys.wiHHYt" -> "authorized_keys": Device or resource busy (16)
# В случае с GPDB 6 проблема не воспроизводится, поскольку используется команда scp.
setup_segment_authorized_keys(){
    if [ -f /tmp/authorized_keys ]; then
        echo "INFO - Copy authorized_keys to /home/${GREENPLUM_USER}/.ssh/authorized_keys"
        cp /tmp/authorized_keys /home/${GREENPLUM_USER}/.ssh/authorized_keys
        chmod 600 /home/${GREENPLUM_USER}/.ssh/authorized_keys
    fi
}

verify_prerequisites() {
    debug "Verify prerequisites"

    file_env "GREENPLUM_PASSWORD"

    check_required_var "GREENPLUM_DATA_DIRECTORY" "${GREENPLUM_DATA_DIRECTORY}"
    check_required_var "GREENPLUM_PASSWORD" "${GREENPLUM_PASSWORD}"
    # Проверяет пароль gpperfmon только в том случае, если gpperfmon включен для развертывания мастера GPDB6.
    if is_gpperfmon_enabled; then
        file_env "GREENPLUM_GPMON_PASSWORD"
        check_required_var "GREENPLUM_GPMON_PASSWORD" "${GREENPLUM_GPMON_PASSWORD}"
    fi
}

is_gpperfmon_enabled() {
    [[ "${GREENPLUM_GPPERFMON_ENABLE}" == "true" &&
       "${gp_major_version}" == "6" &&
       "${GREENPLUM_DEPLOYMENT}" == "master" ]]
}

check_required_var() {
    local var_name=$1
    local var_value=$2
    debug "Variable ${var_name} checking with value: ${var_value}"
    if [ -z "${var_value}" ]; then
        error_and_exit "${var_name} variable is not set!"
    fi
}

setup_gpinitsystem_config(){
    debug "Setup gpinitsystem config"
    if [ -f ${gp_tmp_dir}/gpinitsystem_config ]; then
        echo "INFO - Copy gpinitsystem_config to ${gp_init_config_file}"
        cp ${gp_tmp_dir}/gpinitsystem_config "${gp_init_config_file}"
        chmod 640 "${gp_init_config_file}"
    fi
}

generate_gpinitsystem_config() {
    if [ ! -f "${gp_init_config_file}" ] ; then
        debug "Generate gpinitsystem config if absent"
        cat > "${gp_init_config_file}" <<EOF
ARRAY_NAME="Greenplum in docker"
DATABASE_NAME=${GREENPLUM_DATABASE_NAME}
SEG_PREFIX=${GREENPLUM_SEG_PREFIX}
PORT_BASE=6000
${gp_master_data_dir_prefix}_HOSTNAME=${gp_hostname}
${gp_master_data_dir_prefix}_DIRECTORY=${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}
${gp_master_data_dir_prefix}_PORT=5432
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=8
ENCODING=UNICODE
MACHINE_LIST_FILE=${gp_init_host_file}
declare -a DATA_DIRECTORY=(${GREENPLUM_DATA_DIRECTORY}/00/primary ${GREENPLUM_DATA_DIRECTORY}/01/primary)
EOF
    fi
}

setup_hostfile_gpinitsystem() {
    debug "Setup hostfile gpinitsystem"
    if [ -f ${gp_tmp_dir}/hostfile_gpinitsystem ]; then
        echo "INFO - Copy hostfile_gpinitsystem to ${gp_init_host_file}"
        cp ${gp_tmp_dir}/hostfile_gpinitsystem "${gp_init_host_file}"
        chmod 640 "${gp_init_host_file}"
    fi
}

generate_hostfile_gpinitsystem() {
    if [ ! -f "${gp_init_host_file}" ] ; then
        debug "Generate hostfile gpinitsystem if absent"
        echo "${gp_hostname}" > ${gp_init_host_file}
    fi
}

setup_pxf_config() {
    debug "Setup pxf config dir"
    if [ -d ${gp_tmp_dir}/pxf ]; then
        echo "INFO - Copy pxf config to ${GREENPLUM_PXF_BASE_DIRECTORY}"
        cp -r ${gp_tmp_dir}/pxf/* "${GREENPLUM_PXF_BASE_DIRECTORY}"
        chmod -R 750 "${GREENPLUM_PXF_BASE_DIRECTORY}"
        # chmod 755 "${GREENPLUM_PXF_BASE_DIRECTORY}/logs"
        chmod -R g+s "${GREENPLUM_PXF_BASE_DIRECTORY}"
        pxf cluster sync
    fi
}

execute_custom_init_scripts() {
    local script
    if [ -d "${gp_custom_init_dir}" ] && [ -n "$(ls -A ${gp_custom_init_dir})" ]; then
        echo "INFO - Executing custom initialization scripts"
        for script in "${gp_custom_init_dir}"/*; do
            case "${script}" in
                *.sh)
                    if [ -x "${script}" ]; then
                        echo "INFO - Executing shell script: ${script}"
                        "${script}"
                    else
                        echo "INFO - Sourcing shell script: ${script}"
                        source "${script}"
                    fi
                    ;;
                *.sql)
                    echo "INFO - Executing SQL script: ${script}"
                    psql -v ON_ERROR_STOP=1  --no-psqlrc -U "${GREENPLUM_USER}" -d "${GREENPLUM_DATABASE_NAME}" -f "${script}"
                    ;;
                *)
                    echo "INFO - Ignoring: ${script}"
                    ;;
            esac
        done
        echo "INFO - Finished executing custom initialization scripts"
    fi
}

initialize_and_start_dummy_host() {
    local end_flag=""
    echo "INFO - Initializing dummy host"
    trap "echo 'INFO - Shutdown dummy host' && end_flag=1" TERM INT
    # Сохраняет контейнер запущенным
    while [ "${end_flag}" == '' ]; do
        sleep 1
    done
}

initialize_and_start_gpdb_segments() {
    local end_flag=""
    local arg segment_num segment_type
    echo "INFO - Initializing segment host"
    if [ $# -eq 0 ]; then
        error_and_exit "No segment specifications provided"
    fi
    for arg in "$@"; do
        if [[ ! "$arg" =~ ^[0-9]+:(primary|mirror)$ ]]; then
            error_and_exit "Invalid segment specification format: $arg, expected format: NUMBER:TYPE"
        fi
        IFS=':' read -r segment_num segment_type <<< "$arg"
        setup_segments "${segment_num}" "${segment_type}"
    done
    trap "echo 'INFO - Shutdown segment host' && end_flag=1" TERM INT
    # Сохраняет контейнер запущенным
    while [ "${end_flag}" == '' ]; do
        sleep 1
    done
}

initialize_and_start_gpdb() {
    debug "Initialize and start gpdb"
    local pg_hba="${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}/${GREENPLUM_SEG_PREFIX}-1/pg_hba.conf"
    local pxf_env="${PXF_BASE}/conf/pxf-env.sh"
    local end_flag=""
    local gpdb_already_exists_flag=false

    # Сканирование и добавление ключей хоста
    debug "Scan and add host keys"
    for host in $(cat ${gp_init_host_file}); do
        ssh-keyscan -t rsa $host >> /home/${GREENPLUM_USER}/.ssh/known_hosts 2>/dev/null
    done
    chmod 644 /home/${GREENPLUM_USER}/.ssh/known_hosts

    # Извлечение rsa ssh ключей с хостов
    debug "Fetch rsa ssh keys from hosts"
    gpssh-exkeys -f "${gp_init_host_file}"

    if [ -f "${pg_hba}" ]; then
        debug "Restart GPDB"
        gpdb_already_exists_flag=true
        # В случае использования постоянного тома и уже существующего каталога данных
        # необходимо настроить файл .pgpass для gpperfmon перед запуском GPDB.
        # В противном случае возникнет ошибка:
        # 3rd party error log: Performance Monitor - failed to connect to gpperfmon database: fe_sendauth: no password supplied
        if is_gpperfmon_enabled; then
            echo "*:5432:gpperfmon:gpmon:${GREENPLUM_GPMON_PASSWORD}" > /home/${GREENPLUM_USER}/.pgpass
            chmod 600 /home/${GREENPLUM_USER}/.pgpass
        fi
        echo 'INFO - Start GPDB'
        gpstart -a
    else
        # Инициализация gpdb
        echo "INFO - Initialize GPDB"
        if [ "${gp_major_version}" == "6" ]; then
            gpinitsystem -e ${GREENPLUM_PASSWORD} -ac ${gp_init_config_file} --ignore-warnings
        else
            gpinitsystem -e ${GREENPLUM_PASSWORD} -ac ${gp_init_config_file}
        fi
        # Установка gpperfmon
        if is_gpperfmon_enabled; then
            echo "INFO - Enable gpperfmon"
            USER=${GREENPLUM_USER} gpperfmon_install --enable --password "${GREENPLUM_GPMON_PASSWORD}" --port 5432
            # Необходимо корректно запустить процесс gpsmon. Без этого в некоторых случаях процесс не запускается.
            echo "verbose=1" >> ${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}/${GREENPLUM_SEG_PREFIX}-1/gpperfmon/conf/gpperfmon.conf
            # Настройка параметра gp_interconnect_type на TCP.
            # Без этого в Docker может возникнуть ошибка при работе gpsmon:
            # "send dummy packet failed, sendto failed: Cannot assign requested address",,,,,,,0,,"ic_udpifc.c",7020,
            echo "INFO -  USER=${GREENPLUM_USER} gpconfig -c gp_interconnect_type -v tcp"
            USER=${GREENPLUM_USER} gpconfig -c gp_interconnect_type -v tcp
        fi
        # Настройка diskquota
        if [ "${GREENPLUM_DISKQUOTA_ENABLE}" == "true" ]; then
            echo "INFO - Enable diskquota"
            echo "INFO - createdb diskquota"
            createdb "diskquota"
            # Получение текущего значения shared_preload_libraries
            echo "INFO - psql template1 -t -c \"SHOW shared_preload_libraries\" | xargs"
            gp_shared_preload_libraries=$(psql template1 -t -c "SHOW shared_preload_libraries" | xargs)
            # Получение доступной версии diskquota
            echo "INFO - psql template1 -t -c \"SELECT default_version FROM pg_available_extensions WHERE name = 'diskquota'\" | xargs"
            gp_diskquota_version=$(psql template1 -t -c "SELECT default_version FROM pg_available_extensions WHERE name = 'diskquota'" | xargs)
            # Добавление diskquota в shared_preload_libraries
            if [ -z "${gp_shared_preload_libraries}" ]; then
                echo "INFO - gpconfig -c shared_preload_libraries -v \"diskquota-${gp_diskquota_version}\""
                USER=${GREENPLUM_USER} gpconfig -c shared_preload_libraries -v "diskquota-${gp_diskquota_version}"
            else
                echo "INFO - gpconfig -c shared_preload_libraries -v \"'$gp_shared_preload_libraries,diskquota-${gp_diskquota_version}'\""
                USER=${GREENPLUM_USER} gpconfig -c shared_preload_libraries -v "'$gp_shared_preload_libraries,diskquota-${gp_diskquota_version}'"
            fi
        fi
        if [ "${GREENPLUM_WALG_ENABLE}" == "true" ]; then
            echo "INFO - Set parameters for WAL archiving"
            echo "INFO - gpconfig -c archive_mode -v on"
            USER=${GREENPLUM_USER} gpconfig -c archive_mode -v on
            echo "INFO - gpconfig -c archive_command -v '/bin/true'"
            # Установите параметр archive_command в значение /bin/true,
            # поскольку для WAL-файла не указано место для хранения.
            # Это необходимо для предотвращения ошибок.
            # Используйте скрипт инициализации для установки фактической команды архивирования.
            USER=${GREENPLUM_USER} gpconfig -c archive_command -v "'/bin/true'"
            if [ "${gp_major_version}" == "6" ]; then
                echo "INFO - gpconfig -c wal_level -v archive"
                USER=${GREENPLUM_USER} gpconfig -c wal_level -v archive --skipvalidation
                echo "INFO - psql ${GREENPLUM_DATABASE_NAME} -t -c \"CREATE EXTENSION IF NOT EXISTS gp_pitr;\" | xargs"
                psql ${GREENPLUM_DATABASE_NAME} -t -c "CREATE EXTENSION IF NOT EXISTS gp_pitr;" | xargs
            else
                echo "INFO - gpconfig -c wal_level -v replica"
                USER=${GREENPLUM_USER} gpconfig -c wal_level -v replica --skipvalidation
            fi
        fi
        # Конфигурирование pg_hba
        echo "INFO - Configure pg_hba.conf"
        {
            echo "host all all 0.0.0.0/0 md5"
            echo "host all all ::0/0 md5"
        } >> "${pg_hba}"
        echo "INFO - Restart GPDB"
        gpstop -ar
        sleep 10
    fi
    # Если задано имя базы данных и включена diskquota, создайте расширение и инициализируйте таблицу размеров таблиц.
    if [ "${GREENPLUM_DISKQUOTA_ENABLE}" == "true" ] && [ -n "${GREENPLUM_DATABASE_NAME:-}" ]; then
        echo "INFO - psql ${GREENPLUM_DATABASE_NAME} -t -c \"CREATE EXTENSION IF NOT EXISTS diskquota;\" | xargs"
        psql ${GREENPLUM_DATABASE_NAME} -t -c "CREATE EXTENSION IF NOT EXISTS diskquota;" | xargs
        echo "INFO - psql ${GREENPLUM_DATABASE_NAME} -t -c \"SELECT diskquota.init_table_size_table();\" | xargs"
        psql ${GREENPLUM_DATABASE_NAME} -t -c "SELECT diskquota.init_table_size_table();" | xargs
    fi
    # Установить PXF
    if [ ${GREENPLUM_PXF_ENABLE} == "true" ]; then
        # Настройка pxf
        if [ ! -f "${pxf_env}" ]; then
            echo "INFO - Enable PXF"
            pxf cluster prepare
            pxf cluster register
            echo "INFO - psql ${GREENPLUM_DATABASE_NAME} -t -c \"CREATE EXTENSION IF NOT EXISTS pxf;\" | xargs"
            psql ${GREENPLUM_DATABASE_NAME} -t -c "CREATE EXTENSION IF NOT EXISTS pxf;" | xargs
            echo "INFO - configure JVM options for PXF"
            # Минимизация памяти JVM для работы с PXF.
            # Для docker значение по умолчанию слишком велико.
            echo 'PXF_JVM_OPTS="-Xmx512m -Xms256m"' >> ${pxf_env}
            pxf cluster sync
        fi
        # Настройка пользовательских конфигов
        setup_pxf_config
        echo "INFO - pxf cluster start"
        pxf cluster start
        sleep 10
    fi
    # Мониторинг логов
    debug "Monitor logs"
    trap "kill %1; \
        if [ ${GREENPLUM_PXF_ENABLE} == 'true' ] && [ -f '${pxf_env}' ]; then \
            echo 'INFO - Stop PXF cluster'; \
            pxf cluster stop; \
        fi; \
        gpstop -a -M fast && end_flag=1" INT TERM
    tail -f $(ls ${GREENPLUM_DATA_DIRECTORY}/${gp_master_dir_name}/${GREENPLUM_SEG_PREFIX}-1/${gp_log_dir}/gpdb-* | tail -n1) &
    # Выполнение пользовательских скриптов инициализации.
    if [ "${gpdb_already_exists_flag}" == false ]; then
        echo "INFO - Execute custom init scripts"
        execute_custom_init_scripts
    fi
    #trap
    while [ "${end_flag}" == '' ]; do
        sleep 1
    done
}

case ${GREENPLUM_DEPLOYMENT} in
    "singlenode")
        setup_version_config
        verify_prerequisites
        setup_master
        setup_segments "00" "primary"
        setup_segments "01" "primary"
        setup_gpinitsystem_config
        generate_gpinitsystem_config
        setup_hostfile_gpinitsystem
        generate_hostfile_gpinitsystem
        initialize_and_start_gpdb
        debug "Finish"
        ;;
    "master")
        setup_version_config
        verify_prerequisites
        setup_master
        setup_gpinitsystem_config
        generate_gpinitsystem_config
        setup_hostfile_gpinitsystem
        initialize_and_start_gpdb
        ;;
    "segment")
        setup_segment_authorized_keys
        initialize_and_start_gpdb_segments "$@"
        ;;
    "dummy")
        setup_gpinitsystem_config
        setup_hostfile_gpinitsystem
        initialize_and_start_dummy_host
        ;;
    *)
        error_and_exit "Invalid deployment mode: ${GREENPLUM_DEPLOYMENT}"
        ;;
esac
