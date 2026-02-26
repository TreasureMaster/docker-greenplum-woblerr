#!/bin/bash


debug() {
    if [[ "${GREENPLUM_START_DEBUG:-}" == "true" ]]; then
        echo "[DEBUG] - $1"
    fi
}
