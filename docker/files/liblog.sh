#!/bin/bash

error_and_exit() {
    echo "ERROR - $1"
    exit 1
}

debug() {
    if [[ "${GREENPLUM_START_DEBUG:-}" == "true" ]]; then
        echo "[DEBUG] - $1"
    fi
}
