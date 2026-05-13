#!/usr/bin/env bash
set -euo pipefail

# === Параметры, которые можно переопределить через ENV ===
AIRFLOW_WEBSERVER_URL="http://${AIRFLOW_WEBSERVER_HOST}:8080"
AIRFLOW_API_USER="${AIRFLOW_USERNAME}"      # существующий пользователь для вызова API
AIRFLOW_API_PASSWORD="${AIRFLOW_PASSWORD}"  # его пароль

# AIRFLOW_DEPLOY_USERNAME="${AIRFLOW_DEPLOY_USERNAME}"
# AIRFLOW_DEPLOY_PASSWORD="${AIRFLOW_DEPLOY_PASSWORD}"
AIRFLOW_DEPLOY_FIRSTNAME="${AIRFLOW_DEPLOY_FIRSTNAME:-Airflow}"
AIRFLOW_DEPLOY_LASTNAME="${AIRFLOW_DEPLOY_LASTNAME:-DeployAdmin}"
AIRFLOW_DEPLOY_EMAIL="${AIRFLOW_DEPLOY_EMAIL:-deploy-admin@example.com}"
AIRFLOW_DEPLOY_ROLENAME="${AIRFLOW_DEPLOY_ROLENAME:-Admin,Public}"      # роль в Airflow Web UI

# В Airflow 2.9.3 создание пользователя перенесено в /auth/fab/v1/users (старый /api/v1/users deprecated)
# см. REST API docs. [web:51]

API_URL="${AIRFLOW_WEBSERVER_URL}/auth/fab/v1/users"

echo "Using Airflow API at: ${API_URL}"

# Проверяем доступность API (простой GET)
# echo "Checking Airflow API availability..."
# if ! curl -sS -o /dev/null -w "%{http_code}" \
#     -u "${AIRFLOW_API_USER}:${AIRFLOW_API_PASSWORD}" \
#     "${AIRFLOW_WEBSERVER_URL}/api/v1/health" | grep -qE '200|204'; then
#   echo "Airflow API is not reachable or invalid credentials for ${AIRFLOW_API_USER}"
#   exit 1
# fi

# === Ожидание доступности API с несколькими попытками ===
MAX_RETRIES="${AIRFLOW_API_MAX_RETRIES:-20}"   # сколько раз пробовать
SLEEP_SECONDS="${AIRFLOW_API_RETRY_DELAY:-10}"  # пауза между попытками (сек)

echo "Waiting for Airflow API to become available (max ${MAX_RETRIES} tries, ${SLEEP_SECONDS}s interval)..."

attempt=1
while :; do
  HTTP_CODE="$(
    curl -sS -o /dev/null -w "%{http_code}" \
      -u "${AIRFLOW_API_USER}:${AIRFLOW_API_PASSWORD}" \
      "${AIRFLOW_WEBSERVER_URL}/api/v1/health" || echo "000"
  )"

  if [ "${HTTP_CODE}" = "200" ] || [ "${HTTP_CODE}" = "204" ]; then
    echo "Airflow API is available (HTTP ${HTTP_CODE}) on attempt ${attempt}."
    break
  fi

  if [ "${attempt}" -ge "${MAX_RETRIES}" ]; then
    echo "Airflow API is not reachable after ${MAX_RETRIES} attempts (last HTTP code: ${HTTP_CODE})."
    exit 1
  fi

  echo "Airflow API not ready yet (HTTP ${HTTP_CODE}), attempt ${attempt}/${MAX_RETRIES}, sleeping ${SLEEP_SECONDS}s..."
  attempt=$((attempt + 1))
  sleep "${SLEEP_SECONDS}"
done

# Проверяем, существует ли уже пользователь
echo "Checking if user '${AIRFLOW_DEPLOY_USERNAME}' already exists..."
EXISTING_USER_JSON="$(
  curl -sS \
    -u "${AIRFLOW_API_USER}:${AIRFLOW_API_PASSWORD}" \
    "${API_URL}?username=${AIRFLOW_DEPLOY_USERNAME}"
)"

# Если API вернул объект с этим username — просто выходим
EXISTING_USERNAME="$(echo "${EXISTING_USER_JSON}" | jq -r '.users[0].username // empty' || true)"

if [ -n "${EXISTING_USERNAME}" ] && [ "${EXISTING_USERNAME}" = "${AIRFLOW_DEPLOY_USERNAME}" ]; then
  echo "User '${AIRFLOW_DEPLOY_USERNAME}' already exists, skipping creation."
  exit 0
fi

echo "Creating user '${AIRFLOW_DEPLOY_USERNAME}'..."

CREATE_PAYLOAD="$(
  jq -n \
    --arg username   "${AIRFLOW_DEPLOY_USERNAME}" \
    --arg firstname  "${AIRFLOW_DEPLOY_FIRSTNAME}" \
    --arg lastname   "${AIRFLOW_DEPLOY_LASTNAME}" \
    --arg email      "${AIRFLOW_DEPLOY_EMAIL}" \
    --arg password   "${AIRFLOW_DEPLOY_PASSWORD}" \
    --arg roles_csv  "${AIRFLOW_DEPLOY_ROLENAME}" \
    '{
       username:    $username,
       first_name:  $firstname,
       last_name:   $lastname,
       email:       $email,
       password:    $password,
       active:      true,
       roles:      ( $roles_csv | split(",") | map(. | gsub("^\\s+|\\s+$"; "")) )
     }'
)"
    #    roles: [$role_name]

CREATE_RESPONSE="$(
  curl -sS -w "\n%{http_code}" \
    -u "${AIRFLOW_API_USER}:${AIRFLOW_API_PASSWORD}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "${CREATE_PAYLOAD}" \
    "${API_URL}"
)"

# Отделяем body и HTTP‑код
HTTP_BODY="$(echo "${CREATE_RESPONSE}" | head -n -1)"
HTTP_CODE="$(echo "${CREATE_RESPONSE}" | tail -n 1)"

if [ "${HTTP_CODE}" != "200" ] && [ "${HTTP_CODE}" != "201" ]; then
  echo "Failed to create user. HTTP code: ${HTTP_CODE}"
  echo "Response body:"
  echo "${HTTP_BODY}"
  exit 1
fi

echo "User '${AIRFLOW_DEPLOY_USERNAME}' created/updated successfully."
echo "Response:"
echo "${HTTP_BODY}"
