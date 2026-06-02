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
    local MAX_ATTEMPTS=5
    local attempt=0

    while [[ ! -f /shared/bootstrap/root_pat.txt ]]; do
        attempt=$((attempt + 1))
        if [[ $attempt -gt $MAX_ATTEMPTS ]]; then
            echo "[gitlab-init] ERROR: Max attempts reached (${MAX_ATTEMPTS}), giving up"
            exit 1
        fi
        # echo "[gitlab-init] /shared/bootstrap/root_pat.txt not found yet, waiting 10 seconds..."
        sleep 10
    done

    # echo "[gitlab-init] Found /shared/bootstrap/root_pat.txt, proceeding..."

    # echo "[gitlab-init]: get root token..."
    ROOT_TOKEN=$(cat /shared/bootstrap/root_pat.txt 2>/dev/null || true)
    if [ -z "${ROOT_TOKEN}" ]; then
        echo "[gitlab-init]: ROOT PAT not found in /shared/bootstrap/root_pat.txt" >&2
        return 1
    else
        echo "${ROOT_TOKEN}"
        return 0
    fi
}

export ROOT_TOKEN
# echo "[DEBUG]: Получение токена для дебага"
# get_root_pat "${ROOT_USERNAME}" "${ROOT_PASSWORD}"
# echo "[DEBUG]: реалтьное получение токена"
# ROOT_TOKEN=$(get_root_pat "${ROOT_USERNAME}" "${ROOT_PASSWORD}")
ROOT_TOKEN=$(get_root_pat)

if [[ -z "${ROOT_TOKEN}" ]]; then
    echo "Не удалось получить root токен" >&2
    exit 1
fi

echo "ROOT_TOKEN получен"

# ---------------------------------------------------------------------------- #
#                        2. Создание токена пользователя                       #
# ---------------------------------------------------------------------------- #

create_gitlab_impersonation_token() {
    local user_id="$1"
    local token_name="$2"
    local expires_at="${3:?}"

    curl -sS --request POST \
        --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "{
            \"name\": \"${token_name}\",
            \"scopes\": [\"read_api\"],
            \"expires_at\": \"${expires_at}\"
        }" \
        "${GITLAB_URL}/api/v4/users/${user_id}/impersonation_tokens"
}

# ---------------------------------------------------------------------------- #
#                         3. Создаём пользователей через API                   #
# ---------------------------------------------------------------------------- #
echo "=== Создаём пользователей из users.yaml ==="

# Проверяем наличие файла
if [[ ! -f "${USERS_YAML}" ]]; then
    echo "[ERROR]: Файл ${USERS_YAML} не найден" >&2
    exit 1
fi

# Парсим YAML без python
USERS=$(yq -o=json '.' "${USERS_YAML}" | jq -c '.[]')


RESERVED_USERNAMES=("admin" "root" "support" "help" "dashboard" "profile" "login" "signup" "users" "projects")

# echo "${USERS}" | while IFS= read -r user_json; do
while IFS= read -r user_json; do
    username=$(echo "${user_json}" | jq -r '.username')
    email=$(echo "${user_json}" | jq -r '.email')
    name=$(echo "${user_json}" | jq -r '.name')
    password=$(echo "${user_json}" | jq -r '.password')

    # Проверка на зарезервированные имена
    if printf '%s\n' "${RESERVED_USERNAMES[@]}" | grep -qi "^${username}$"; then
        echo "[WARNING]: Пропуск: имя ${username} зарезервировано"
        continue
    fi

    # Проверка длины пароля
    if [[ ${#password} -lt 8 ]]; then
        echo "[ERROR]: Пропуск: пароль ${username} менее 8 символов"
        continue
    fi

    # Проверяем, существует ли пользователь
    existing=$(curl -sS --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        "${GITLAB_URL}/api/v4/users?username=${username}" \
        | jq -r '.[0].username // empty')
    
    if [[ -n "${existing}" ]]; then
        echo "[INFO]: Пользователь ${username} уже существует"
        continue
    fi

    # Создаём пользователя
    result=$(curl -sS --request POST \
        --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "{
            \"username\": \"${username}\",
            \"email\": \"${email}\",
            \"name\": \"${name}\",
            \"password\": \"${password}\",
            \"skip_confirmation\": true
        }" \
        "${GITLAB_URL}/api/v4/users")

    user_id=$(echo "${result}" | jq -r '.id // empty')

    if [[ -n "${user_id}" && "${user_id}" != "null" ]]; then
        echo "[INFO]: Создан пользователь: ${username} (ID=${user_id})"
    else
        echo "[ERROR]: Ошибка создания ${username}: ${result}" >&2
    fi

    if [[ "${username}" == "${GITLAB_API_USER}" ]]; then
        echo "[INFO]: Создаём GitLab API token для ${username}"
        # TOKEN_EXPIRES_AT="$(date -d '+360 days' +%F)"
        TOKEN_EXPIRES_AT="$(date -u -d "@$(( $(date -u +%s) + 360*24*60*60 ))" +%F)"
        token_result=$(create_gitlab_impersonation_token "${user_id}" "${GITLAB_API_TOKEN_NAME}" "${TOKEN_EXPIRES_AT}")
        GITLAB_API_TOKEN=$(echo "${token_result}" | jq -r '.token // empty')

        if [[ -z "${GITLAB_API_TOKEN}" ]]; then
            echo "[ERROR]: Не удалось получить token для ${username}: ${token_result}" >&2
            exit 1
        fi

        export GITLAB_API_TOKEN
        echo "[INFO]: GITLAB_API_TOKEN установлен в переменную окружения"
    fi
done <<< "${USERS}"

# ---------------------------------------------------------------------------- #
#                         4. Запрет регистрации через API                      #
# ---------------------------------------------------------------------------- #
echo "=== Запрещаем регистрацию ==="

curl -sS --request PUT \
  --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
  --data "signup_enabled=false" \
  --data "can_create_group=false" \
  --data "default_project_visibility=private" \
  --data "default_snippet_visibility=private" \
  --data "default_group_visibility=private" \
  "${GITLAB_URL}/api/v4/application/settings" \
  | jq -r '.signup_enabled, .can_create_group, .default_project_visibility, .default_group_visibility, .default_snippet_visibility'


echo "[INFO]: Регистрация запрещена"
echo "=== Инициализация GitLab завершена ==="
