#!/bin/bash

set -euo pipefail


jenkins_debug_curl() {
  local label="$1"; shift
  echo "[JENKINS-DEBUG] ${label}: $*"
  curl -sS -o /tmp/jenkins_api_last_response.txt -w "HTTP_CODE=%{http_code}\n" "$@"
}

wait_for_jenkins() {
  local jenkins_url="${1:?}"
  local max_attempts="${2:-60}"
  local sleep_seconds="${3:-5}"
  local attempt=1

  while (( attempt <= max_attempts )); do
    if curl -fsS "${jenkins_url}/login" >/dev/null 2>&1; then
      return 0
    fi
    echo "Waiting for Jenkins: attempt ${attempt}/${max_attempts}"
    sleep "${sleep_seconds}"
    ((attempt++))
  done

  echo "ERROR: Jenkins did not become ready"
  return 1
}

# jenkins_get_crumb() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"

#   curl -fsS -u "${jenkins_user}:${jenkins_pass}" \
#     "${jenkins_url}/crumbIssuer/api/json" | jq -r '.crumb'
# }

# jenkins_get_crumb() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"

#   echo "[JENKINS] Getting crumb from ${jenkins_url}/crumbIssuer/api/json"
#   local out
#   out=$(jenkins_debug_curl "crumbIssuer" \
#     -u "${jenkins_user}:${jenkins_pass}" \
#     "${jenkins_url}/crumbIssuer/api/json") || {
#       echo "[JENKINS-ERROR] crumbIssuer curl failed"
#       cat /tmp/jenkins_api_last_response.txt || true
#       return 1
#     }

#   echo "${out}" | tee /tmp/jenkins_api_last_crumb_raw.txt
#   local code
#   code=$(echo "${out}" | sed -n 's/^HTTP_CODE=//p')

#   if [[ "${code}" != "200" ]]; then
#     echo "[JENKINS-ERROR] crumbIssuer returned HTTP ${code}"
#     echo "[JENKINS-ERROR] Body:"
#     cat /tmp/jenkins_api_last_response.txt || true
#     return 1
#   fi

#   echo "${out}" | jq -r '.crumb'
# }

# jenkins_get_crumb() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"

#   echo "[JENKINS] Getting crumb from ${jenkins_url}/crumbIssuer/api/json"

#   # Показываем ответ и код
#   local body
#   local code

#   body=$(curl -sS -u "${jenkins_user}:${jenkins_pass}" \
#     -w "HTTP_CODE=%{http_code}" \
#     "${jenkins_url}/crumbIssuer/api/json")

#   code=$(echo "${body}" | sed -n 's/^.*HTTP_CODE=\([0-9][0-9][0-9]\)$/\1/p')
#   body="${body%HTTP_CODE=*}"

#   echo "[JENKINS-DEBUG] crumb HTTP_CODE=${code}"
#   echo "[JENKINS-DEBUG] crumb body:"
#   printf '%s\n' "${body}"

#   if [[ "${code}" != "200" ]]; then
#     echo "[JENKINS-ERROR] crumbIssuer returned HTTP ${code}"
#     return 1
#   fi

#   # теперь уже безопасно парсим JSON
#   echo "${body}" | jq -r '.crumb'
# }

# jenkins_get_crumb() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"

#   echo "[JENKINS] Getting crumb from ${jenkins_url}/crumbIssuer/api/json"

#   # Забираем только JSON + HTTP-код, никаких чужих echo между ними
#   local body_and_code
#   body_and_code=$(curl -sS -u "${jenkins_user}:${jenkins_pass}" \
#     -w "HTTP_CODE=%{http_code}" \
#     "${jenkins_url}/crumbIssuer/api/json") || {
#       echo "[JENKINS-ERROR] crumbIssuer curl failed"
#       return 1
#     }

#   # Выделяем код и тело
#   local code body
#   code="${body_and_code##*HTTP_CODE=}"
#   body="${body_and_code%HTTP_CODE=*}"

#   echo "[JENKINS-DEBUG] crumb HTTP_CODE=${code}"
#   echo "[JENKINS-DEBUG] crumb body: ${body}"

#   if [[ "${code}" != "200" ]]; then
#     echo "[JENKINS-ERROR] crumbIssuer returned HTTP ${code}"
#     return 1
#   fi

#   # Здесь body — чистый JSON, можно безопасно парсить
#   echo "${body}" | jq -r '.crumb'
# }

# jenkins_get_crumb() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"

#   echo "[JENKINS] Getting crumb from ${jenkins_url}/crumbIssuer/api/json"

#   local body_and_code
#   body_and_code=$(curl -sS -u "${jenkins_user}:${jenkins_pass}" \
#     -w "HTTP_CODE=%{http_code}" \
#     "${jenkins_url}/crumbIssuer/api/json") || {
#       echo "[JENKINS-ERROR] crumbIssuer curl failed"
#       return 1
#     }

#   local code body
#   code="${body_and_code##*HTTP_CODE=}"
#   body="${body_and_code%HTTP_CODE=*}"

#   echo "[JENKINS-DEBUG] crumb HTTP_CODE=${code}"
#   echo "[JENKINS-DEBUG] crumb body: ${body}"

#   if [[ "${code}" != "200" ]]; then
#     echo "[JENKINS-ERROR] crumbIssuer returned HTTP ${code}"
#     return 1
#   fi

#   local crumb
#   crumb="$(echo "${body}" | jq -r '.crumb')"
#   # подстрахуемся
#   crumb="$(echo "${crumb}" | tr -d '\r\n')"

#   echo "[JENKINS-DEBUG] crumb value: '${crumb}'"
#   echo "${crumb}"
# }

# jenkins_get_crumb() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"

#   echo "[JENKINS] Getting crumb from ${jenkins_url}/crumbIssuer/api/json" >&2

#   local body_and_code
#   body_and_code=$(curl -sS -u "${jenkins_user}:${jenkins_pass}" \
#     -w "HTTP_CODE=%{http_code}" \
#     "${jenkins_url}/crumbIssuer/api/json") || {
#       echo "[JENKINS-ERROR] crumbIssuer curl failed" >&2
#       return 1
#     }

#   local code body crumb
#   code="${body_and_code##*HTTP_CODE=}"
#   body="${body_and_code%HTTP_CODE=*}"

#   echo "[JENKINS-DEBUG] crumb HTTP_CODE=${code}" >&2
#   echo "[JENKINS-DEBUG] crumb body: ${body}" >&2

#   if [[ "${code}" != "200" ]]; then
#     echo "[JENKINS-ERROR] crumbIssuer returned HTTP ${code}" >&2
#     return 1
#   fi

#   crumb="$(echo "${body}" | jq -r '.crumb' | tr -d '\r\n')"

#   echo "[JENKINS-DEBUG] crumb value: '${crumb}'" >&2
#   printf '%s' "${crumb}"
# }

jenkins_get_crumb() {
  local jenkins_url="${1:?}"
  local jenkins_user="${2:?}"
  local jenkins_pass="${3:?}"

  echo "[JENKINS] Getting crumb from ${jenkins_url}/crumbIssuer/api/json" >&2

  local tmp_cookie
  tmp_cookie="$(mktemp)"

  local body_and_code
  body_and_code=$(curl -sS -c "${tmp_cookie}" -u "${jenkins_user}:${jenkins_pass}" \
    -w "HTTP_CODE=%{http_code}" \
    "${jenkins_url}/crumbIssuer/api/json") || {
      echo "[JENKINS-ERROR] crumbIssuer curl failed" >&2
      rm -f "${tmp_cookie}"
      return 1
    }

  local code body crumb
  code="${body_and_code##*HTTP_CODE=}"
  body="${body_and_code%HTTP_CODE=*}"

  echo "[JENKINS-DEBUG] crumb HTTP_CODE=${code}" >&2
  echo "[JENKINS-DEBUG] crumb body: ${body}" >&2

  if [[ "${code}" != "200" ]]; then
    echo "[JENKINS-ERROR] crumbIssuer returned HTTP ${code}" >&2
    rm -f "${tmp_cookie}"
    return 1
  fi

  crumb="$(echo "${body}" | jq -r '.crumb' | tr -d '\r\n')"
  echo "[JENKINS-DEBUG] crumb value: '${crumb}'" >&2

  # Возвращаем в stdout сразу crumb и cookie-файл через разделитель
  printf '%s|%s' "${crumb}" "${tmp_cookie}"
}

# jenkins_upsert_secret_text_credential() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"
#   local credentials_id="${4:?}"
#   local secret_value="${5:?}"
#   local description="${6:-Bootstrap GitLab token}"

#   local crumb
#   crumb="$(jenkins_get_crumb "${jenkins_url}" "${jenkins_user}" "${jenkins_pass}")"

#   curl -fsS -u "${jenkins_user}:${jenkins_pass}" \
#     -H "Jenkins-Crumb: ${crumb}" \
#     -H "Content-Type: application/x-www-form-urlencoded" \
#     --data-urlencode "json={
#       \"\": \"0\",
#       \"credentials\": {
#         \"scope\": \"GLOBAL\",
#         \"id\": \"${credentials_id}\",
#         \"description\": \"${description}\",
#         \"secret\": \"${secret_value}\",
#         \"stapler-class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\",
#         \"\$class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\"
#       }
#     }" \
#     "${jenkins_url}/credentials/store/system/domain/_/createCredentials"
# }

# jenkins_upsert_secret_text_credential() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"
#   local credentials_id="${4:?}"
#   local secret_value="${5:?}"
#   local description="${6:-Bootstrap secret}"

#   local crumb
#   crumb="$(jenkins_get_crumb "${jenkins_url}" "${jenkins_user}" "${jenkins_pass}")" || {
#     echo "[JENKINS-ERROR] Cannot get crumb"
#     return 1
#   }

#   echo "[JENKINS] Upserting secret text credential id=${credentials_id}"

#   jenkins_debug_curl "createCredentials(${credentials_id})" \
#     -u "${jenkins_user}:${jenkins_pass}" \
#     -H "Jenkins-Crumb: ${crumb}" \
#     -H "Content-Type: application/x-www-form-urlencoded" \
#     --data-urlencode "json={
#       \"\": \"0\",
#       \"credentials\": {
#         \"scope\": \"GLOBAL\",
#         \"id\": \"${credentials_id}\",
#         \"description\": \"${description}\",
#         \"secret\": \"${secret_value}\",
#         \"stapler-class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\",
#         \"\$class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\"
#       }
#     }" \
#     "${jenkins_url}/credentials/store/system/domain/_/createCredentials" \
#     | tee /tmp/jenkins_api_last_create_credentials.txt

#   local code
#   code=$(grep '^HTTP_CODE=' /tmp/jenkins_api_last_create_credentials.txt | sed 's/^HTTP_CODE=//')
#   if [[ "${code}" != "200" && "${code}" != "204" ]]; then
#     echo "[JENKINS-ERROR] createCredentials returned HTTP ${code}"
#     echo "[JENKINS-ERROR] Body:"
#     cat /tmp/jenkins_api_last_response.txt || true
#     return 1
#   fi
# }

# jenkins_upsert_secret_text_credential() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"
#   local credentials_id="${4:?}"
#   local secret_value="${5:?}"
#   local description="${6:-Bootstrap secret}"

#   local crumb
#   crumb="$(jenkins_get_crumb "${jenkins_url}" "${jenkins_user}" "${jenkins_pass}")" || {
#     echo "[JENKINS-ERROR] Cannot get crumb"
#     return 1
#   }

#   echo "[JENKINS] Upserting secret text credential id=${credentials_id}"

#   local response
#   response=$(curl -sS -u "${jenkins_user}:${jenkins_pass}" \
#     -H "Jenkins-Crumb: ${crumb}" \
#     -H "Content-Type: application/x-www-form-urlencoded" \
#     -w "HTTP_CODE=%{http_code}" \
#     --data-urlencode "json={
#       \"\": \"0\",
#       \"credentials\": {
#         \"scope\": \"GLOBAL\",
#         \"id\": \"${credentials_id}\",
#         \"description\": \"${description}\",
#         \"secret\": \"${secret_value}\",
#         \"stapler-class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\",
#         \"\$class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\"
#       }
#     }" \
#     "${jenkins_url}/credentials/store/system/domain/_/createCredentials")

#   local code body
#   code="${response##*HTTP_CODE=}"
#   body="${response%HTTP_CODE=*}"

#   echo "[JENKINS-DEBUG] createCredentials HTTP_CODE=${code}"
#   [[ -n "${body}" ]] && echo "[JENKINS-DEBUG] createCredentials body: ${body}"

#   # Jenkins часто отдаёт 200 или 204, иногда 302; считаем 2xx успешным
#   if [[ ! "${code}" =~ ^2[0-9][0-9]$ ]]; then
#     echo "[JENKINS-ERROR] createCredentials returned HTTP ${code}"
#     return 1
#   fi
# }

# jenkins_upsert_secret_text_credential() {
#   local jenkins_url="${1:?}"
#   local jenkins_user="${2:?}"
#   local jenkins_pass="${3:?}"
#   local credentials_id="${4:?}"
#   local secret_value="${5:?}"
#   local description="${6:-Bootstrap secret}"

#   local crumb
#   crumb="$(jenkins_get_crumb "${jenkins_url}" "${jenkins_user}" "${jenkins_pass}")" || {
#     echo "[JENKINS-ERROR] Cannot get crumb"
#     return 1
#   }

#   echo "[JENKINS] Upserting secret text credential id=${credentials_id}"

#   # JSON в одну строку
#   local json_payload
#   json_payload=$(
#     jq -nc \
#       --arg scope "GLOBAL" \
#       --arg id "${credentials_id}" \
#       --arg desc "${description}" \
#       --arg secret "${secret_value}" \
#       '{
#         "": "0",
#         "credentials": {
#           "scope": $scope,
#           "id": $id,
#           "description": $desc,
#           "secret": $secret,
#           "stapler-class": "org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl",
#           "$class": "org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"
#         }
#       }'
#   )

#   echo "[JENKINS-DEBUG] Using crumb header: Jenkins-Crumb: ${crumb}"
#   echo "[JENKINS-DEBUG] POST ${jenkins_url}/credentials/store/system/domain/_/createCredentials"
#   echo "[JENKINS-DEBUG] JSON payload: ${json_payload}"

#   local response
#   response=$(
#     curl -sS -u "${jenkins_user}:${jenkins_pass}" \
#       -H "Jenkins-Crumb: ${crumb}" \
#       -H "Content-Type: application/x-www-form-urlencoded" \
#       -w "HTTP_CODE=%{http_code}" \
#       --data-urlencode "json=${json_payload}" \
#       "${jenkins_url}/credentials/store/system/domain/_/createCredentials"
#   )

#   local code body
#   code="${response##*HTTP_CODE=}"
#   body="${response%HTTP_CODE=*}"

#   echo "[JENKINS-DEBUG] createCredentials HTTP_CODE=${code}"
#   [[ -n "${body}" ]] && echo "[JENKINS-DEBUG] createCredentials body: ${body}"

#   if [[ ! "${code}" =~ ^2[0-9][0-9]$ ]]; then
#     echo "[JENKINS-ERROR] createCredentials returned HTTP ${code}"
#     return 1
#   fi
# }

jenkins_upsert_secret_text_credential() {
  local jenkins_url="${1:?}"
  local jenkins_user="${2:?}"
  local jenkins_pass="${3:?}"
  local credentials_id="${4:?}"
  local secret_value="${5:?}"
  local description="${6:-Bootstrap secret}"

  local crumb_and_cookie
  crumb_and_cookie="$(jenkins_get_crumb "${jenkins_url}" "${jenkins_user}" "${jenkins_pass}")" || {
    echo "[JENKINS-ERROR] Cannot get crumb" >&2
    return 1
  }

  local crumb cookie_file
  crumb="${crumb_and_cookie%%|*}"
  cookie_file="${crumb_and_cookie#*|}"

  echo "[JENKINS] Upserting secret text credential id=${credentials_id}" >&2
  echo "[JENKINS-DEBUG] Using crumb header: Jenkins-Crumb: ${crumb}" >&2
  echo "[JENKINS-DEBUG] Using cookie file: ${cookie_file}" >&2

  local json_payload
  json_payload=$(
    jq -nc \
      --arg scope "GLOBAL" \
      --arg id "${credentials_id}" \
      --arg desc "${description}" \
      --arg secret "${secret_value}" \
      '{
        "": "0",
        "credentials": {
          "scope": $scope,
          "id": $id,
          "description": $desc,
          "secret": $secret,
          "stapler-class": "org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl",
          "$class": "org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"
        }
      }'
  )

  local response
  response=$(
    curl -sS -b "${cookie_file}" -u "${jenkins_user}:${jenkins_pass}" \
      -H "Jenkins-Crumb: ${crumb}" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -w "HTTP_CODE=%{http_code}" \
      --data-urlencode "json=${json_payload}" \
      "${jenkins_url}/credentials/store/system/domain/_/createCredentials"
  )

  local code body
  code="${response##*HTTP_CODE=}"
  body="${response%HTTP_CODE=*}"

  echo "[JENKINS-DEBUG] createCredentials HTTP_CODE=${code}" >&2
  [[ -n "${body}" ]] && echo "[JENKINS-DEBUG] createCredentials body: ${body}" >&2

  rm -f "${cookie_file}"

  # Считаем успешными все 2xx и 302 (редирект после успешного POST)
  if [[ "${code}" =~ ^2[0-9][0-9]$ || "${code}" == "302" ]]; then
    echo "[JENKINS] createCredentials finished with HTTP ${code}, treating as success" >&2
    return 0
  fi

  echo "[JENKINS-ERROR] createCredentials returned HTTP ${code}" >&2
  return 1

}

wait_for_jenkins "${JENKINS_INNER_URL}" 30 10

# GITLAB_TOKEN="$(cat /run/secrets/gitlab_token)"
if [[ -z "${GITLAB_API_TOKEN:-}" ]]; then
  echo "ERROR: GITLAB_API_TOKEN is empty"
  exit 1
fi

# токен для работы с Gitlab пользователя cdjksnd (прибито гвоздями)
jenkins_upsert_secret_text_credential \
  "${JENKINS_INNER_URL}" \
  "${JENKINS_ADMIN_USER}" \
  "${JENKINS_ADMIN_PASSWORD}" \
  "airflow-config-update" \
  "${GITLAB_API_TOKEN}" \
  "GitLab API token"

# И обновление ID проекта, для которого используется токен
if [[ -n "${GITLAB_API_PROJECT_ID:-}" ]]; then
  jenkins_upsert_secret_text_credential \
    "${JENKINS_INNER_URL}" \
    "${JENKINS_ADMIN_USER}" \
    "${JENKINS_ADMIN_PASSWORD}" \
    "gitlab-api-project-id" \
    "${GITLAB_API_PROJECT_ID}" \
    "GitLab API project id"
fi
