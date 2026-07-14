#!/usr/bin/env bash

set -euo pipefail

VERSION="0.12.4"

PROJECT_NAME="${PROJECT_NAME:-dwh-gp}"
ARCHIVE_DIR="$HOME/images"
ARCHIVE="${ARCHIVE_DIR}/dwh-init--${VERSION}.tar.gz"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
STATE_FILE=".config.sha"

cd "$(dirname "$0")"

FORCE_DEPLOY=false
START_DEBUG=false

# --- Разбор аргументов ---

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)
      FORCE_DEPLOY=true
      ;;
    -v|--verbose)
      START_DEBUG=true
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "[ERROR] Неизвестный параметр: $1"
      echo "       Используйте: -f|--force, -v|--verbose"
      exit 1
      ;;
    *)
      # позиционные аргументы сейчас не используем
      ;;
  esac
  shift
done

echo "[INFO] Запуск скрипта деплоя для проекта: ${PROJECT_NAME}"
$FORCE_DEPLOY && echo "[INFO] Включён режим принудительного деплоя (force)"
$START_DEBUG && echo "[INFO] Включён подробный вывод (verbose/debug)"

debug() {
  if [[ "${START_DEBUG}" == "true" ]]; then
    echo "[DEBUG] - $1" >&2
  fi
}

# --- Проверка зависимостей ---

command -v jq >/dev/null 2>&1 || {
  echo "[ERROR] Утилита 'jq' не найдена в PATH. Установите jq и повторите."
  exit 1
}

command -v yq >/dev/null 2>&1 || {
  echo "[ERROR] Утилита 'yq' не найдена в PATH. Установите yq (mikefarah/yq) и повторите."
  exit 1
}

command -v docker >/dev/null 2>&1 || {
  echo "[ERROR] Утилита 'docker' не найдена в PATH. Установите Docker и повторите."
  exit 1
}

if command -v docker compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
  echo "[INFO] Используется 'docker compose' CLI"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
  echo "[INFO] Используется 'docker-compose' CLI"
else
  echo "[ERROR] Ни 'docker compose', ни 'docker-compose' не найдены. Установите Docker Compose."
  exit 1
fi

# --- Загрузка .env в окружение и подготовка env_args ---

env_args=()

if [[ -f "$ENV_FILE" ]]; then
  echo "[INFO] Найден файл окружения: ${ENV_FILE}"
  debug "Загружаю переменные окружения из ${ENV_FILE} для интерполяции compose"
  set -a
  . "$ENV_FILE"
  set +a
  env_args+=(--env-file "$ENV_FILE")
else
  echo "[INFO] Файл окружения ${ENV_FILE} не найден, запускаем без --env-file"
fi

# --- Вспомогательные функции ---

get_image_from_tar() {
  local tag
  tag="$(tar -xzOf "$ARCHIVE" manifest.json 2>/dev/null \
    | jq -r '[.[] | .RepoTags] | add | .[0]' 2>/dev/null || true)"
  # trim пробелов/табов/переводов строки
  tag="${tag#"${tag%%[![:space:]]*}"}"
  tag="${tag%"${tag##*[![:space:]]}"}"
  printf '%s' "$tag"
}

get_local_id() {
  debug "get_local_id func: аргумент='$1'"
  docker image inspect --format '{{.Id}}' "$1" 2>/dev/null || true
}

load_archive_and_get_id() {
  local tmp_out tmp_tag tmp_id
  tmp_out="$(mktemp)"
  echo "[INFO] Выполняю docker load для архива: ${ARCHIVE}" >&2

  if ! docker load -i "$ARCHIVE" >"$tmp_out"; then
    echo "[ERROR] docker load не удалось для архива ${ARCHIVE}" >&2
    rm -f "$tmp_out"
    return 1
  fi

  tmp_tag="$(awk -F':' '/Loaded image:/ {print $2 ":" $3; exit}' "$tmp_out" | xargs || true)"
  rm -f "$tmp_out"

  if [[ -z "$tmp_tag" ]]; then
    echo "[ERROR] Не удалось определить тег образа после docker load" >&2
    return 1
  fi

  echo "[INFO] После docker load получен образ: ${tmp_tag}" >&2

  tmp_id="$(get_local_id "$tmp_tag")"
  if [[ -z "$tmp_id" ]]; then
    echo "[ERROR] Не удалось получить Id образа '${tmp_tag}' после docker load" >&2
    return 1
  fi

  echo "[INFO] Id образа из архива: ${tmp_id}" >&2
  echo "$tmp_id"
}

# Извлекаем образы из compose с подстановкой переменных окружения
get_compose_images() {
  local raw
  mapfile -t raw < <(yq '.services[].image' "$COMPOSE_FILE" 2>/dev/null || true)

  local resolved=()
  local line expanded

  for line in "${raw[@]}"; do
    [[ -z "$line" ]] && continue
    line="${line%\"}"
    line="${line#\"}"
    expanded="$(eval "echo \"$line\"")"

    if [[ "$expanded" == "$line" && "$line" == *'${'* ]]; then
      echo "[WARN] Не удалось интерполировать переменные в строке образа: ${line}"
    fi

    resolved+=("$expanded")
  done

  printf '%s\n' "${resolved[@]}"
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

echo "[INFO] Извлекаю имя образа из архива: ${ARCHIVE}"
ARCHIVE_IMAGE="$(get_image_from_tar)"
debug "Образ из архива (после trim): '${ARCHIVE_IMAGE}'"

if [[ -n "$ARCHIVE_IMAGE" ]]; then
  echo "[INFO] Образ из архива: ${ARCHIVE_IMAGE}"
else
  echo "[WARN] Не удалось извлечь образ из архива ${ARCHIVE}, проверка архивного образа будет частично ограничена"
fi

mapfile -t ALL_IMAGES < <(get_compose_images)

debug "Образы из ${COMPOSE_FILE} (после интерполяции .env):"
for img in "${ALL_IMAGES[@]}"; do
  [[ -z "$img" ]] && continue
  debug "       - ${img}"
done

HUB_IMAGES=()

for img in "${ALL_IMAGES[@]}"; do
  [[ -z "$img" ]] && continue
  if [[ -n "$ARCHIVE_IMAGE" && "$img" == "$ARCHIVE_IMAGE" ]]; then
    echo "[INFO] Образ ${img} будет считаться локальным (из архива)"
  else
    HUB_IMAGES+=("$img")
  fi
done

# Архивный образ
if [[ -n "$ARCHIVE_IMAGE" ]]; then
  debug "ARCHIVE_IMAGE='${ARCHIVE_IMAGE}'"
  LOCAL_ID_BEFORE="$(get_local_id "$ARCHIVE_IMAGE")"
  debug "LOCAL_ID_BEFORE='${LOCAL_ID_BEFORE}'"
  if [[ -n "$LOCAL_ID_BEFORE" ]]; then
    echo "[INFO] Текущий Id локального архивного образа ${ARCHIVE_IMAGE}: ${LOCAL_ID_BEFORE}"
  else
    echo "[INFO] Локальный образ ${ARCHIVE_IMAGE} ещё не загружен"
  fi

  NEW_ID="$(load_archive_and_get_id)" || {
    echo "[ERROR] Прерывание: ошибка при загрузке архивного образа"
    exit 1
  }

  if [[ -n "$LOCAL_ID_BEFORE" && -n "$NEW_ID" && "$LOCAL_ID_BEFORE" != "$NEW_ID" ]]; then
    echo "[INFO] Id архивного образа изменился: требуется пересоздание контейнеров"
    need_recreate=1
  elif [[ -n "$LOCAL_ID_BEFORE" && -n "$NEW_ID" ]]; then
    echo "[INFO] Id архивного образа не изменился"
  fi
fi

# Образы из Docker Hub
for img in "${HUB_IMAGES[@]}"; do
  echo "[INFO] Проверяю образ из Docker Hub: ${img}"
  LOCAL_BEFORE="$(get_local_id "$img")"
  if [[ -n "$LOCAL_BEFORE" ]]; then
    echo "       Текущий Id: ${LOCAL_BEFORE}"
  else
    echo "       Локального образа нет, будет загружен"
  fi

  if ! docker pull "$img" >/dev/null 2>&1; then
    echo "       [ERROR] Не удалось выполнить docker pull для ${img}"
    exit 1
  fi

  LOCAL_AFTER="$(get_local_id "$img")"

  if [[ -z "$LOCAL_AFTER" ]]; then
    echo "       [ERROR] После docker pull не удалось получить локальный Id для ${img}"
    exit 1
  fi

  if [[ -n "$LOCAL_BEFORE" && "$LOCAL_BEFORE" != "$LOCAL_AFTER" ]]; then
    echo "       Id образа изменился: ${LOCAL_BEFORE} → ${LOCAL_AFTER}"
    need_recreate=1
  else
    echo "       Id образа не изменился"
  fi
done

# --- Проверка конфигурации (compose + .env) ---

config_changed=0
current_sha="$(calc_config_sha)"
prev_sha=""
[[ -f "$STATE_FILE" ]] && prev_sha="$(cat "$STATE_FILE")"

echo "[INFO] Текущий хеш конфигурации (compose + env): ${current_sha}"
if [[ -n "$prev_sha" ]]; then
  echo "[INFO] Предыдущий хеш конфигурации: ${prev_sha}"
fi

if [[ "$current_sha" != "$prev_sha" ]]; then
  config_changed=1
  echo "[INFO] Конфигурация изменилась (${COMPOSE_FILE} и/или ${ENV_FILE})"
  echo "$current_sha" > "$STATE_FILE"
else
  echo "[INFO] Конфигурация не изменилась"
fi

# --- Решение: up / up --force-recreate / start ---

if [[ "$FORCE_DEPLOY" == "true" ]]; then
  echo "[INFO] Принудительный режим: запускаю ${COMPOSE_CMD[*]} up -d --force-recreate"
  "${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d --force-recreate
elif [[ "$config_changed" -eq 1 ]]; then
  echo "[INFO] Запускаю ${COMPOSE_CMD[*]} up -d --force-recreate (изменена конфигурация)"
  "${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d --force-recreate
elif [[ "$need_recreate" -eq 1 ]]; then
  echo "[INFO] Запускаю ${COMPOSE_CMD[*]} up -d (изменились образы)"
  "${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d
else
  echo "[INFO] Образы и конфигурация не изменились"
  if "${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" ps -a --format json | grep -q .; then
    echo "[INFO] Контейнеры уже существуют, запускаю ${COMPOSE_CMD[*]} start"
    "${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" start
  else
    echo "[INFO] Контейнеры ещё не созданы, запускаю ${COMPOSE_CMD[*]} up -d"
    "${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "${env_args[@]}" up -d
  fi
fi

# --- Ожидание завершения dwh-init и проверка результата ---

INIT_SERVICE="dwh-init"

# Находим имя контейнера по сервису и проекту
INIT_CONTAINER="$("${COMPOSE_CMD[@]}" -p "$PROJECT_NAME" -f "$COMPOSE_FILE" ps -q "$INIT_SERVICE" 2>/dev/null || true)"

if [[ -z "$INIT_CONTAINER" ]]; then
  echo "[ERROR] Контейнер сервиса ${INIT_SERVICE} не найден, пропускаю проверку его результата"
else
  echo "[INFO] Ожидаю завершения инициализирующего контейнера ${INIT_SERVICE} (${INIT_CONTAINER})"
  # Ждём завершения и получаем код выхода
  docker wait "$INIT_CONTAINER" >/dev/null 2>&1 || true
  EXIT_CODE="$(docker inspect --format '{{.State.ExitCode}}' "$INIT_CONTAINER" 2>/dev/null || echo "")"

  if [[ -z "$EXIT_CODE" ]]; then
    echo "[ERROR] Не удалось получить код выхода контейнера ${INIT_CONTAINER}"
  elif [[ "$EXIT_CODE" -eq 0 ]]; then
    echo "[INFO] Инициализация (${INIT_SERVICE}) завершилась успешно (ExitCode=0)"
  else
    echo "[ERROR] Инициализация (${INIT_SERVICE}) завершилась с ошибкой (ExitCode=${EXIT_CODE})"
  fi
fi

# Проверка логов dwh-init
if [[ "$EXIT_CODE" -eq 0 ]]; then
  if docker logs "$INIT_CONTAINER" 2>/dev/null | grep -q "All initialization complete!"; then
    echo "[INFO] Подтверждение: найдена строка 'All initialization complete!' в логах ${INIT_SERVICE}"
  else
    echo "[WARN] ExitCode=0, но строка 'All initialization complete!' в логах ${INIT_SERVICE} не найдена"
  fi
fi

echo "[INFO] Скрипт успешно завершён"
