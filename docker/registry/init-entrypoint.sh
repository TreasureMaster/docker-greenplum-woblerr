#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------- #
#                         1. Конфигурация из ENV                               #
# ---------------------------------------------------------------------------- #
REGISTRY_HOST="${REGISTRY_HOST:-local-registry}"
REGISTRY_PORT="${REGISTRY_PORT:-5000}"
REGISTRY_LOAD_ADDR="${REGISTRY_HOST}:${REGISTRY_PORT}"
IMAGES_DIR="${IMAGES_DIR:-/opt/offline-images}"
MODE="${MODE:-safe}"  # safe | force
CRANE_ENABLED="${CRANE_ENABLED:-false}"

echo "Starting offline registry initialization..."
echo "   Mode: ${MODE}"
echo "   Registry: ${REGISTRY_LOAD_ADDR}"
echo "   Images Dir: ${IMAGES_DIR}"
echo "   Crane: ${CRANE_ENABLED}"

# ---------------------------------------------------------------------------- #
#                         2. Проверка доступности registry                     #
# ---------------------------------------------------------------------------- #
wait_for_registry() {
    local max_attempts=60
    local attempt=0
    local url="http://${REGISTRY_LOAD_ADDR}/v2/"
    
    echo "Waiting for registry at ${url}..."
    until curl -s -o /dev/null -w "%{http_code}" "${url}" | grep -q "200"; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
            echo "Registry is not ready after ${max_attempts} attempts."
            exit 1
        fi
        echo "   Attempt ${attempt}/${max_attempts}... retrying in 2s"
        sleep 2
    done
    echo "Registry is ready!"
}

# ---------------------------------------------------------------------------- #
#                         3. Функции работы с registry (из load-images.sh)     #
# ---------------------------------------------------------------------------- #
image_exists_in_registry() {
    local image="$1"  # формат registry.local:5000/repo:tag
    local repo tag
    repo="${image#${REGISTRY_LOAD_ADDR}/}"   # repo:tag
    tag="${repo##*:}"
    repo="${repo%:*}"
    local url="http://${REGISTRY_LOAD_ADDR}/v2/${repo}/manifests/${tag}"
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" "${url}" || echo "000")
    [[ "${status}" == "200" ]]
}

get_image_digest_in_registry() {
    local image="$1"
    local repo tag
    repo="${image#${REGISTRY_LOAD_ADDR}/}"
    tag="${repo##*:}"
    repo="${repo%:*}"
    local url="http://${REGISTRY_LOAD_ADDR}/v2/${repo}/manifests/${tag}"
    curl -sSI \
        -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "${url}" \
        | awk -F': ' '/^Docker-Content-Digest:/ {gsub("\r","",$2); print $2}'
}

delete_image_from_registry() {
    local image="$1"
    local repo tag digest
    repo="${image#${REGISTRY_LOAD_ADDR}/}"
    tag="${repo##*:}"
    repo="${repo%:*}"
    digest=$(get_image_digest_in_registry "${image}")
    if [[ -z "${digest}" ]]; then
        echo "  Не удалось получить digest для ${image}"
        return 0
    fi
    local url="http://${REGISTRY_LOAD_ADDR}/v2/${repo}/manifests/${digest}"
    echo "  Удаляю манифест ${repo}@${digest} ..."
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${url}" || echo "000")
    if [[ "${status}" != "202" ]]; then
        echo "  WARNING: delete вернул HTTP ${status}" >&2
    else
        echo "  Удаление запрошено."
    fi
}

# ---------------------------------------------------------------------------- #
#                         4. Обработка архивов                                 #
# ---------------------------------------------------------------------------- #
process_archives() {
    shopt -s nullglob
    local archives=( "${IMAGES_DIR}"/*.tar.gz )
    shopt -u nullglob

    if [[ ${#archives[@]} -eq 0 ]]; then
        echo "No archives found in ${IMAGES_DIR}" >&2
        exit 1
    fi

    echo "Found ${#archives[@]} archive(s) to process"

    for arch in "${archives[@]}"; do
        echo
        echo "=== Processing ${arch} ==="
        
        # Загрузка образа
        if [[ "${CRANE_ENABLED}" == "true" ]]; then
            # Crane может работать с tar-архивами напрямую
            echo "   Loading with crane..."
            crane push "${arch}" "${REGISTRY_LOAD_ADDR}/temp:loading" 2>/dev/null || {
                # Если crane не может, fallback на docker
                echo "   Crane failed, falling back to docker..."
                LOAD_OUTPUT=$(docker load -i "${arch}")
                echo "${LOAD_OUTPUT}"
            }
        fi
        
        # Стандартный путь через docker load
        LOAD_OUTPUT=$(docker load -i "${arch}")
        echo "${LOAD_OUTPUT}"
        
        # Извлечение тега из вывода
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
        
        # Проверка существования в registry
        if [[ "${MODE}" == "force" ]]; then
            if image_exists_in_registry "${TARGET_IMAGE}"; then
                echo "Image exists in registry, deleting before re-push (force mode)..."
                delete_image_from_registry "${TARGET_IMAGE}"
            fi
        else
            if image_exists_in_registry "${TARGET_IMAGE}"; then
                echo "Image already exists in registry, skipping (safe mode)."
                # Очищаем локальный образ
                docker rmi "${IMAGE_TAG}" >/dev/null 2>&1 || true
                continue
            fi
        fi
        
        # Тегирование и пуш
        echo "Tagging ${IMAGE_TAG} as ${TARGET_IMAGE}..."
        docker tag "${IMAGE_TAG}" "${TARGET_IMAGE}"
        
        echo "Pushing ${TARGET_IMAGE} ..."
        if [[ "${CRANE_ENABLED}" == "true" ]] && command -v crane >/dev/null 2>&1; then
            crane push "${IMAGE_TAG}" "${TARGET_IMAGE}"
        else
            docker push "${TARGET_IMAGE}"
        fi
        
        # Очистка локальных образов
        docker rmi "${TARGET_IMAGE}" >/dev/null 2>&1 || true
        docker rmi "${IMAGE_TAG}" >/dev/null 2>&1 || true
    done
}

# ---------------------------------------------------------------------------- #
#                         5. Основной поток                                    #
# ---------------------------------------------------------------------------- #
wait_for_registry
process_archives

echo
echo "All images processed successfully!"
