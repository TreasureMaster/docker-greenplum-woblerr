#!/usr/bin/env bash

set -euo pipefail

VERSION="0.12.4"

PROJECT_NAME="${PROJECT_NAME:-dwh-gp}"
ARCHIVE="~/images/dwh-init--${VERSION}.tar.gz"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
STATE_FILE=".config.sha"

cd "$(dirname "$0")"

# --- Проверка зависимостей ---

command -v jq >/dev/null 2>&1 || {
  echo "Ошибка: утилита 'jq' не найдена в PATH. Установите jq и повторите."
  exit 1
}

command -v yq >/dev/null 2>&1 || {
  echo "Ошибка: утилита 'yq' не найдена в PATH. Установите yq (mikefarah/yq) и повторите."
  exit 1
}

command -v docker >/dev/null 2>&1 || {
  echo "Ошибка: утилита 'docker' не найдена в PATH. Установите Docker и повторите."
  exit 1
}

if command -v docker compose >/dev/null 2>&1; then
  COMPOSE_BIN="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_BIN="docker-compose"
else
  echo "Ошибка: ни 'docker compose', ни 'docker-compose' не найдены. Установите Docker Compose."
  exit 1
fi

# --- Вспомогательные функции ---

env_args=()
[[ -f "$ENV_FILE" ]] && env_args+=(--env-file "$ENV_FILE")

get_image_from_tar() {
  tar -xzOf "$ARCHIVE" manifest.json 2>/dev/null \
    | jq -r '[.[] | .RepoTags] | add | .[0]' 2>/dev/null || true
}

get_local_id() {
  docker image inspect --format '{{.Id}}' "$1" 2>/dev/null || true
}

load_archive_and_get_id() {
  local tmp_out tmp_tag tmp_id
  tmp_out="$(mktemp)"
  docker load -i "$ARCHIVE" >"$tmp_out"
  tmp_tag="$(awk -F':' '/Loaded image:/ {print $2 ":" $3; exit}' "$tmp_out" | xargs || true)"
  rm -f "$tmp_out"

  if [[ -n "$tmp_tag" ]]; then
    tmp_id="$(get_local_id "$tmp_tag")"
    echo "$tmp_id"
  else
    echo ""
  fi
}

get_compose_images() {
  yq '.services[].image' "$COMPOSE_FILE" 2>/dev/null || true
}

calc_config_sha() {
  local sha
  if [[ -f "$ENV_FILE" ]]; then
    sha="$(sha256sum "$COMPOSE_FILE" "$ENV_FILE" | awk '{print $1}' | sha256sum | awk '{print $1}')"
  else
    sha="$(sha256sum "$COMPOSE_FILE" | awk '{print $1}')"
  fi
  echo "$sha"
}

# --- Проверка образов ---

need_recreate=0

ARCHIVE_IMAGE="$(get_image_from_tar)"

mapfile -t ALL_IMAGES < <(get_compose_images)

HUB_IMAGES=()

for img in "${ALL_IMAGES[@]}"; do
  [[ -z "$img" ]] && continue
  if [[ -n "$ARCHIVE_IMAGE" && "$img" == "$ARCHIVE_IMAGE" ]]; then
    :
  else
    HUB_IMAGES+=("$img")
  fi
done

# Архивный образ
if [[ -n "$ARCHIVE_IMAGE" ]]; then
  LOCAL_ID_BEFORE="$(get_local_id "$ARCHIVE_IMAGE")"
  NEW_ID="$(load_archive_and_get_id)"

  if [[ -n "$LOCAL_ID_BEFORE" && -n "$NEW_ID" && "$LOCAL_ID_BEFORE" != "$NEW_ID" ]]; then
    need_recreate=1
  fi
fi

# Образы из Docker Hub
for img in "${HUB_IMAGES[@]}"; do
  LOCAL_BEFORE="$(get_local_id "$img")"
  docker pull "$img" >/dev/null 2>&1 || true
  LOCAL_AFTER="$(get_local_id "$img")"

  if [[ -n "$LOCAL_BEFORE" && -n "$LOCAL_AFTER" && "$LOCAL_BEFORE" != "$LOCAL_AFTER" ]]; then
    need_recreate=1
  fi
done

# --- Проверка конфигурации (compose + .env) ---

config_changed=0
current_sha="$(calc_config_sha)"
prev_sha=""
[[ -f "$STATE_FILE" ]] && prev_sha="$(cat "$STATE_FILE")"

if [[ "$current_sha" != "$prev_sha" ]]; then
  config_changed=1
  echo "$current_sha" > "$STATE_FILE"
fi

# --- Решение: up / up --force-recreate / start ---

if [[ "$config_changed" -eq 1 ]]; then
  # Конфигурация изменилась: пересоздать контейнеры гарантированно
  "$COMPOSE_BIN" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d --force-recreate
elif [[ "$need_recreate" -eq 1 ]]; then
  # Образы изменились: пересоздать, но без доп. force-recreate
  "$COMPOSE_BIN" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d
else
  # Образы и конфиг не изменились
  if "$COMPOSE_BIN" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" ps -a --format json | grep -q .; then
    "$COMPOSE_BIN" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" start
  else
    "$COMPOSE_BIN" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d
  fi
fi
