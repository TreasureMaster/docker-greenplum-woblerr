#!/bin/bash

# Common env vars
gp_tmp_dir="/tmp/greenplum-cfg"
if [ -d "${gp_custom_init_dir}" ] && [ -n "$(ls -A "${gp_custom_init_dir}" 2>/dev/null)" ]; then
    GP_PASSWORD_FILE="${GREENPLUM_PASSWORD_FILE}"
fi
