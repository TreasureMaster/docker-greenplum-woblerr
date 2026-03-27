#!/bin/bash

set -euo pipefail

# Переменные берутся из ENV docker-compose, не из файла
# GITLAB_URL="${GITLAB_URL:-http://gitlab}"
# ROOT_USERNAME="${ROOT_USERNAME:-root}"
# ROOT_PASSWORD="${ROOT_PASSWORD}"
# USERS_YAML="${USERS_YAML:-/usr/local/bin/gitlab-rails-init/users.yaml}"

echo "=== Инициализация GitLab через API ==="

# ---------------------------------------------------------------------------- #
#                    1. Получаем root Personal Access Token                    #
# ---------------------------------------------------------------------------- #
echo "=== Создаём/получаем root PAT ==="

get_root_pat() {
    local username="$1"
    local password="$2"
    
    # Получаем user ID
    local user_id
    user_id=$(curl -sS --request GET \
        --header "Content-Type: application/json" \
        --user "${username}:${password}" \
        "${GITLAB_URL}/api/v4/user" \
        | jq -r '.id' 2>/dev/null)
    
    if [[ -z "${user_id}" || "${user_id}" == "null" ]]…l token
    token=$(curl -sS --request POST \
        --header "Content-Type: application/json" \
        --user "${username}:${password}" \
        --data '{"name":"bootstrap-token","scopes":["api","write_repository"],"expires_at":"'"$(date -d '+365 days' +%Y-%m-%d)"'"}' \
        "${GITLAB_URL}/api/v4/users/${user_id}/personal_access_tokens" \
        | jq -r '.token // empty' 2>/dev/null)
    
    if [[ -n "${token}" ]]; then
        echo "${token}"
        return 0
    fi
    
    return 1
}

export ROOT_TOKEN
ROOT_TOKEN=$(get_root_pat "${ROOT_USERNAME}" "${ROOT_PASSWORD}")

if [[ -z "${ROOT_TOKEN}" ]]; then
    echo "Не удалось получить root токен" >&2
    exit 1
fi

echo "ROOT_TOKEN получен"
