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
