#!/usr/bin/env bash
set -euo pipefail

# Загрузка переменных окружения
. ./registryenv.sh

# ---------------------------------------------------------------------------- #
#                         1. Определение режима работы                         #
# ---------------------------------------------------------------------------- #

MODE="${1:-safe}"
if [[ "${MODE}" != "safe" && "${MODE}" != "force" ]]; then
  echo "Usage: $0 [safe|force]" >&2
  exit 1
fi
echo "Mode: ${MODE}"

echo "Using registry: ${REGISTRY_LOAD_ADDR}"

# ---------------------------------------------------------------------------- #
#                        2. Проверка локального registry                       #
# ---------------------------------------------------------------------------- #

# Проверяем, что контейнер registry жив
if ! docker ps --format '{{.Names}}' | grep -q "^${REGISTRY_CONTAINER_NAME}$"; then
  echo "[ERROR]: registry контейнер не найден среди работающих." >&2
  echo "Убедись, что docker-compose.yml уже поднял сервис registry." >&2
  exit 1
fi

# ---------------------------------------------------------------------------- #
#                           3. Дополнительные функции                          #
# ---------------------------------------------------------------------------- #

image_exists_in_registry() {
  # Проверка существования докер-образа в реестре
  local image="$1"  # формат registry.local:5000/repo:tag

  local repo tag
  # Это удаление префикса с помощью параметрического расширения ${var#pattern}.
  # ${image#...} — удаляет самый короткий совпадающий префикс.
  # Удаляется строка "${REGISTRY_LOAD_ADDR}/", то есть "registry.local:5000/".
  repo="${image#${REGISTRY_LOAD_ADDR}/}"   # получаем repo:tag
  # ${var##pattern} — удаляет самый длинный совпадающий префикс до последнего вхождения шаблона.
  # ##*: — удаляет всё * до последнего двоеточия (включая его).
  # Используется ##, а не #, чтобы корректно обрабатывать репозитории с / в имени, например: myapp/backend:1.2.3
  # Остаётся только тег.
  tag="${repo##*:}"
  # ${var%pattern} — удаляет самый короткий совпадающий суффикс.
  # %:* — удаляет всё от последнего двоеточия до конца (включая :).
  # Остаётся только имя репозитория.
  repo="${repo%:*}"

  local url="http://${REGISTRY_LOAD_ADDR}/v2/${repo}/manifests/${tag}"

  # проверка HTTP кода, присваивает status = "000", если ошибка работы curl
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "${url}" || echo "000")
  # возвращает только 0, если код 200, или 1, если код другой
  [[ "${status}" == "200" ]]
}

# Получить digest (sha256:...) манифеста образа в registry
get_image_digest_in_registry() {
  local image="$1"  # формат registry.local:5000/repo:tag

  local repo tag
  repo="${image#${REGISTRY_LOAD_ADDR}/}"   # repo:tag
  tag="${repo##*:}"
  repo="${repo%:*}"

  local url="http://${REGISTRY_LOAD_ADDR}/v2/${repo}/manifests/${tag}"

  # Важно: Accept заголовок для получения манифеста v2 и digest в заголовке
  curl -sSI \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "${url}" \
    | awk -F': ' '/^Docker-Content-Digest:/ {gsub("\r","",$2); print $2}'
}

# Удалить манифест образа по digest
delete_image_from_registry() {
  local image="$1"  # формат registry.local:5000/repo:tag

  local repo tag digest
  repo="${image#${REGISTRY_LOAD_ADDR}/}"   # repo:tag
  tag="${repo##*:}"
  repo="${repo%:*}"

  digest=$(get_image_digest_in_registry "${image}")
  if [[ -z "${digest}" ]]; then
    echo "  Не удалось получить digest для ${image} (возможно, нет такого образа)"
    return 0
  fi

  local url="http://${REGISTRY_LOAD_ADDR}/v2/${repo}/manifests/${digest}"
  echo "  Удаляю из registry манифест ${repo}@${digest} ..."

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${url}" || echo "000")
  if [[ "${status}" != "202" ]]; then
    echo "  WARNING: delete вернул HTTP ${status} для ${url}" >&2
  else
    echo "  Удаление запрошено, образ будет убран после garbage-collect (если включён)."
    # удаляем старые слои
    # NOTE отключено, т.к. работает с ошибками
    # docker exec ${REGISTRY_CONTAINER_NAME} registry garbage-collect /etc/distribution/config.yml
  fi
}

# ---------------------------------------------------------------------------- #
#                         4. Обработка архивов образов                         #
# ---------------------------------------------------------------------------- #

# сканируем папку архивов образов
shopt -s nullglob   # если пусто, то ничего не выводим
archives=( ${ARCHIVE_GLOB} )
shopt -u nullglob

# '#' - это оператор подсчета, определяет количество элементов массива (или строки, если проверяется строка)
if [[ ${#archives[@]} -eq 0 ]]; then
  echo "No archives found in ${IMAGES_DIR}" >&2
  exit 1
fi

for arch in "${archives[@]}"; do
  echo
  echo "=== Processing ${arch}"

  LOAD_OUTPUT=$(docker load -i "${arch}")
  echo "${LOAD_OUTPUT}"

  IMAGE_TAG=$(printf '%s\n' "${LOAD_OUTPUT}" \
    | grep -E 'Loaded image:' \
    | tail -n1 \
    | sed -E 's/^Loaded image: //')

  if [[ -z "${IMAGE_TAG}" ]]; then
    echo "Cannot detect image tag from docker load output, skipping" >&2
    continue
  fi

  echo "Loaded image tag: ${IMAGE_TAG}"

  TARGET_IMAGE="${REGISTRY_LOAD_ADDR}/${IMAGE_TAG}"

  if [[ "${MODE}" == "force" ]]; then
    if image_exists_in_registry "${TARGET_IMAGE}"; then
      echo "Image ${TARGET_IMAGE} exists in registry, deleting before re-push (force mode)..."
      delete_image_from_registry "${TARGET_IMAGE}"
    else
      echo "Image ${TARGET_IMAGE} not found in registry, pushing..."
    fi
  else
    if image_exists_in_registry "${TARGET_IMAGE}"; then
      echo "Image ${TARGET_IMAGE} already exists in registry, skipping (safe)."
      continue
    fi
  fi

  echo "Tagging ${IMAGE_TAG} as ${TARGET_IMAGE}..."
  docker tag "${IMAGE_TAG}" "${TARGET_IMAGE}"

  echo "Pushing ${TARGET_IMAGE} ..."
  docker push "${TARGET_IMAGE}"

  docker rmi "${TARGET_IMAGE}" >/dev/null 2>&1 || true
done

echo
echo "All images processed."
