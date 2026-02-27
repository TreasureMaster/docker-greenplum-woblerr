#!/usr/bin/env bash

# Load libraries
. /liblog.sh
. /libenv.sh

uid=$(id -u)

if [ "${uid}" = "0" ]; then
    # Пользовательский часовой пояс.
    if [ "${TZ}" != "Etc/UTC" ]; then
        cp /usr/share/zoneinfo/${TZ} /etc/localtime
        echo "${TZ}" > /etc/timezone
    fi
    # Пользовательская группа.
    if [ "${GREENPLUM_GROUP}" != "gpadmin" ] || [ "${GREENPLUM_GID}" != "1001" ]; then
        groupmod -g ${GREENPLUM_GID} -n ${GREENPLUM_GROUP} gpadmin
    fi
    # Настройка пользователя.
    if [ "${GREENPLUM_USER}" != "gpadmin" ] || [ "${GREENPLUM_UID}" != "1001" ]; then
        debug "Change user to ${GREENPLUM_USER} or uid to ${GREENPLUM_UID}"
        java_home_path=$(dirname $(dirname $(readlink -f $(which java))))
        usermod -g ${GREENPLUM_GID} -l ${GREENPLUM_USER} -u ${GREENPLUM_UID} -m -d /home/${GREENPLUM_USER} gpadmin
        echo "source /usr/local/greenplum-db/greenplum_path.sh" > /home/${GREENPLUM_USER}/.bashrc
        echo "export JAVA_HOME=/${java_home_path}" >> /home/${GREENPLUM_USER}/.bashrc
        echo 'export PATH="/usr/local/pxf/bin:${PATH}"' >> /home/${GREENPLUM_USER}/.bashrc
        # echo "export PXF_BASE=${GREENPLUM_DATA_DIRECTORY}/pxf" >> /home/${GREENPLUM_USER}/.bashrc
        echo "export PXF_BASE=${GREENPLUM_PXF_BASE_DIRECTORY}" >> /home/${GREENPLUM_USER}/.bashrc
        mkdir -m 700 -p /home/${GREENPLUM_USER}/.ssh
        mkdir -p /home/${GREENPLUM_USER}/pxf
        ssh-keygen -q -f /home/${GREENPLUM_USER}/.ssh/id_rsa -t rsa -N ""
    fi
    if [ "${GREENPLUM_PXF_BASE_DIRECTORY}" != "${GREENPLUM_DATA_DIRECTORY}/pxf" ]; then
        debug "Change PXF_BASE value"
        echo "export PXF_BASE=${GREENPLUM_PXF_BASE_DIRECTORY}" >> /home/${GREENPLUM_USER}/.bashrc
    fi
    debug "Correction user:group"
    # Коррекция user:group, если они были переопределены в env.
    chown -R ${GREENPLUM_USER}:${GREENPLUM_GROUP} \
        /home/${GREENPLUM_USER} \
        ${GREENPLUM_DATA_DIRECTORY} \
        ${GREENPLUM_PXF_BASE_DIRECTORY} \
        /docker-entrypoint-initdb.d
    # Коррекция user:group для стартовых файлов
    chown ${GREENPLUM_USER}:${GREENPLUM_GROUP} \
        /start_gpdb.sh \
        /liblog.sh \
        /libenv.sh
    # Копирование проброшенных конфигурационных файлов, чтобы избежать изменения прав на хосте
    mkdir -p ${gp_tmp_dir}
    debug "Copy gpinitsystem config to local tmp"
    if [ -f /tmp/gpinitsystem_config ]; then
        echo "INFO - Copy gpinitsystem_config to ${gp_tmp_dir}"
        cp /tmp/gpinitsystem_config "${gp_tmp_dir}"
    fi
    debug "Copy hostfile gpinitsystem to local tmp"
    if [ -f /tmp/hostfile_gpinitsystem ]; then
        echo "INFO - Copy hostfile_gpinitsystem to ${gp_tmp_dir}"
        cp /tmp/hostfile_gpinitsystem "${gp_tmp_dir}"
    fi
    chown -R ${GREENPLUM_USER}:${GREENPLUM_GROUP} ${gp_tmp_dir}
fi

# Старт SSH сервера.
debug "Start ssh server"
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi
mkdir -p /run/sshd
/usr/sbin/sshd
sleep 2

# Выполнение команды.
debug "Start start_gpdb.sh"
if [ "${uid}" = "0" ]; then
    exec gosu ${GREENPLUM_USER} "$@"
else
    exec "$@"
fi
