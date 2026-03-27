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
    while [[ ! -f /shared/bootstrap/root_pat.txt ]]; do
        echo "[gitlab-init] /shared/bootstrap/root_pat.txt not found yet, waiting 10 seconds..."
        sleep 10
    done

    echo "[gitlab-init] Found /shared/bootstrap/root_pat.txt, proceeding..."

    echo "[gitlab-init]: get root token..."
    ROOT_TOKEN=$(cat /shared/bootstrap/root_pat.txt 2>/dev/null || true)
    if [ -z "${ROOT_TOKEN}" ]; then
        echo "[gitlab-init]: ROOT PAT not found in /shared/bootstrap/root_pat.txt" >&2
        return 1
    else
        echo "${ROOT_TOKEN}"
        return 0
    fi
    # local username="$1"
    # local password="$2"

    # # Получаем user ID
    # local user_id
    # echo "[DEBUG]: А что вообще возвращает curl для user_id:"
    # curl -sS --request GET \
    #     --header "Content-Type: application/json" \
    #     --user "${username}:${password}" \
    #     "${GITLAB_URL}/api/v4/user"

    # user_id=$(curl -sS --request GET \
    #     --header "Content-Type: application/json" \
    #     --user "${username}:${password}" \
    #     "${GITLAB_URL}/api/v4/user" \
    #     | jq -r '.id' 2>/dev/null)

    # echo "[DEBUG]: Полученный use id: ${user_id}"
    # if [[ -z "${user_id}" || "${user_id}" == "null" ]]; then
    #     echo "Не удалось получить user_id для ${username}" >&2
    #     return 1
    # fi

    # # Проверяем существующие токены
    # local existing_token
    # echo "[DEBUG]: А что вообще возвращает curl для existing_token:"
    # curl -sS --request GET \
    #     --header "PRIVATE-TOKEN: ${password}" \
    #     "${GITLAB_URL}/api/v4/users/${user_id}/personal_access_tokens?name=bootstrap-token"

    # existing_token=$(curl -sS --request GET \
    #     --header "PRIVATE-TOKEN: ${password}" \
    #     "${GITLAB_URL}/api/v4/users/${user_id}/personal_access_tokens?name=bootstrap-token" \
    #     | jq -r '.[0].token // empty' 2>/dev/null)

    # if [[ -n "${existing_token}" ]]; then
    #     echo "${existing_token}"
    #     return 0
    # fi

    # # Создаём новый токен
    # local token
    # echo "[DEBUG]: А что вообще возвращает curl для token:"
    # curl -sS --request POST \
    #     --header "Content-Type: application/json" \
    #     --user "${username}:${password}" \
    #     --data '{"name":"bootstrap-token","scopes":["api","write_repository"],"expires_at":"'"$(date -d '+365 days' +%Y-%m-%d)"'"}' \
    #     "${GITLAB_URL}/api/v4/users/${user_id}/personal_access_tokens"

    # token=$(curl -sS --request POST \
    #     --header "Content-Type: application/json" \
    #     --user "${username}:${password}" \
    #     --data '{"name":"bootstrap-token","scopes":["api","write_repository"],"expires_at":"'"$(date -d '+365 days' +%Y-%m-%d)"'"}' \
    #     "${GITLAB_URL}/api/v4/users/${user_id}/personal_access_tokens" \
    #     | jq -r '.token // empty' 2>/dev/null)

    # if [[ -n "${token}" ]]; then
    #     echo "${token}"
    #     return 0
    # fi

    # return 1
}

export ROOT_TOKEN
echo "[DEBUG]: Получение токена для дебага"
get_root_pat "${ROOT_USERNAME}" "${ROOT_PASSWORD}"
echo "[DEBUG]: реалтьное получение токена"
ROOT_TOKEN=$(get_root_pat "${ROOT_USERNAME}" "${ROOT_PASSWORD}")

if [[ -z "${ROOT_TOKEN}" ]]; then
    echo "Не удалось получить root токен" >&2
    exit 1
fi

echo "ROOT_TOKEN получен"

# ---------------------------------------------------------------------------- #
#                         2. Создаём пользователей через API                   #
# ---------------------------------------------------------------------------- #
# echo "=== Создаём пользователей из users.yaml ==="

# # Проверяем наличие файла
# if [[ ! -f "${USERS_YAML}" ]]; then
#     echo "❌ Файл ${USERS_YAML} не найден" >&2
#     exit 1
# fi

# # Парсим YAML через Python
# USERS=$(python3 -c "
# import yaml, json
# with open('${USERS_YAML}') as f:
#     data = yaml.safe_load(f)
#     print(json.dumps(data if isinstance(data, list) else [data]))
# " | jq -c '.[]')

# RESERVED_USERNAMES=("admin" "root" "support" "help" "dashboard" "profile" "login" "signup" "users" "projects")

# echo "${USERS}" | while IFS= read -r user_json; do
#     username=$(echo "${user_json}" | jq -r '.username')
#     email=$(echo "${user_json}" | jq -r '.email')
#     name=$(echo "${user_json}" | jq -r '.name')
#     password=$(echo "${user_json}" | jq -r '.password')
    
#     # Проверка на зарезервированные имена
#     if printf '%s\n' "${RESERVED_USERNAMES[@]}" | grep -qi "^${username}$"; then
#         echo "⚠️ Пропуск: имя ${username} зарезервировано"
#         continue
#     fi
    
#     # Проверка длины пароля
#     if [[ ${#password} -lt 8 ]]; then
#         echo "⚠️ Пропуск: пароль ${username} менее 8 символов"
#         continue
#     fi
    
#     # Проверяем, существует ли пользователь
#     existing=$(curl -sS --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
#         "${GITLAB_URL}/api/v4/users?username=${username}" \
#         | jq -r '.[0].username // empty')
    
#     if [[ -n "${existing}" ]]; then
#         echo "⏭️ Пользователь ${username} уже существует"
#         continue
#     fi
    
#     # Создаём пользователя
#     result=$(curl -sS --request POST \
#         --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
#         --header "Content-Type: application/json" \
#         --data "{
#             \"username\": \"${username}\",
#             \"email\": \"${email}\",
#             \"name\": \"${name}\",
#             \"password\": \"${password}\",
#             \"skip_confirmation\": true
#         }" \
#         "${GITLAB_URL}/api/v4/users")
    
#     user_id=$(echo "${result}" | jq -r '.id // empty')
    
#     if [[ -n "${user_id}" && "${user_id}" != "null" ]]; then
#         echo "✅ Создан пользователь: ${username} (ID=${user_id})"
#     else
#         echo "❌ Ошибка создания ${username}: ${result}" >&2
#     fi
# done

# ---------------------------------------------------------------------------- #
#                         3. Запрет регистрации через API                      #
# ---------------------------------------------------------------------------- #
# echo "=== Запрещаем регистрацию ==="

# curl -sS --request PUT \
#     --header "PRIVATE-TOKEN: ${ROOT_TOKEN}" \
#     --header "Content-Type: application/json" \
#     --data '{
#         "signup_enabled": false,
#         "can_create_group": false,
#         "default_project_visibility": 0,
#         "default_snippet_visibility": 0,
#         "default_group_visibility": 0
#     }' \
#     "${GITLAB_URL}/api/v4/application/settings" \
#     | jq -r '.signup_enabled'

# echo "✅ Регистрация запрещена"
# echo "=== Инициализация GitLab завершена ==="
