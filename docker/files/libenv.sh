#!/bin/bash

# Common env vars
gp_tmp_dir="/tmp/greenplum-cfg"
if [ -d "${GREENPLUM_SECRETS_DIR}" ] && [ -n "$(ls -A "${GREENPLUM_SECRETS_DIR}" 2>/dev/null)" ]; then
    GP_PASSWORD_FILE="${GREENPLUM_PASSWORD_FILE}"
fi
