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
CRANE_FLAGS="--insecure"  # Разрешаем HTTP

echo "Starting offline registry initialization (crane-only)..."
echo "   Mode: ${MODE}"
echo "   Registry: ${REGISTRY_LOAD_ADDR}"
echo "   Images Dir: ${IMAGES_DIR}"

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
#                         3. Функции работы с registry (через crane)           #
# ---------------------------------------------------------------------------- #
image_exists_in_registry() {
    local image="$1"  # формат registry.local:5000/repo:tag
    # crane digest возвращает 0, если образ есть, и ошибку, если нет
    crane digest "${CRANE_FLAGS}" "${image}" >/dev/null 2>&1
}

delete_image_from_registry() {
    local image="$1"
    echo "  Удаляю ${image} из registry..."
    crane delete "${CRANE_FLAGS}" "${image}" 2>/dev/null || {
        echo "  WARNING: не удалось удалить ${image}" >&2
    }
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

    echo "📦 Found ${#archives[@]} archive(s) to process"

    for arch in "${archives[@]}"; do
        echo
        echo "=== Processing ${arch} ==="
        
        # Извлекаем имя образа из архива (читаем манифест)
        # Используем crane для чтения метаданных из tar
        IMAGE_REF=$(gunzip -c "${arch}" | crane manifest - 2>/dev/null | jq -r '.config.labels."org.opencontainers.image.ref.name"' 2>/dev/null || echo "")
        
        # Если метка не найдена, пробуем извлечь из имени файла
        if [[ -z "${IMAGE_REF}" ]]; then
            # Предполагаем, что имя файла = имя образа (без .tar.gz)
            IMAGE_REF=$(basename "${arch}" .tar.gz)
            echo "Using filename as image ref: ${IMAGE_REF}"
        fi
        
        TARGET_IMAGE="${REGISTRY_LOAD_ADDR}/${IMAGE_REF}"
        echo "Detected image ref: ${IMAGE_REF}"
        echo "   Target: ${TARGET_IMAGE}"
        
        # Проверка существования в registry
        if [[ "${MODE}" == "force" ]]; then
            if image_exists_in_registry "${TARGET_IMAGE}"; then
                echo "Image exists in registry, deleting before re-push (force mode)..."
                delete_image_from_registry "${TARGET_IMAGE}"
            fi
        else
            if image_exists_in_registry "${TARGET_IMAGE}"; then
                echo "Image already exists in registry, skipping (safe mode)."
                continue
            fi
        fi
        
        # Пуш напрямую из архива в реестр
        echo "Pushing ${TARGET_IMAGE} ..."
        gunzip -c "${arch}" | crane push "${CRANE_FLAGS}" - "${TARGET_IMAGE}"
        
        echo "Successfully pushed ${TARGET_IMAGE}"
    done
}

# ---------------------------------------------------------------------------- #
#                         5. Основной поток                                    #
# ---------------------------------------------------------------------------- #
wait_for_registry
process_archives

echo
echo "All images processed successfully!"
