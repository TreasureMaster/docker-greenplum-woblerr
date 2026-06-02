#!/bin/bash

set -euo pipefail


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

  curl -fsS -u "${jenkins_user}:${jenkins_pass}" \
    "${jenkins_url}/crumbIssuer/api/json" | jq -r '.crumb'
}

jenkins_upsert_secret_text_credential() {
  local jenkins_url="${1:?}"
  local jenkins_user="${2:?}"
  local jenkins_pass="${3:?}"
  local credentials_id="${4:?}"
  local secret_value="${5:?}"
  local description="${6:-Bootstrap GitLab token}"

  local crumb
  crumb="$(jenkins_get_crumb "${jenkins_url}" "${jenkins_user}" "${jenkins_pass}")"

  curl -fsS -u "${jenkins_user}:${jenkins_pass}" \
    -H "Jenkins-Crumb: ${crumb}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "json={
      \"\": \"0\",
      \"credentials\": {
        \"scope\": \"GLOBAL\",
        \"id\": \"${credentials_id}\",
        \"description\": \"${description}\",
        \"secret\": \"${secret_value}\",
        \"stapler-class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\",
        \"\$class\": \"org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl\"
      }
    }" \
    "${jenkins_url}/credentials/store/system/domain/_/createCredentials"
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
  "gitlab-api-token" \
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
