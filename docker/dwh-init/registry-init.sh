#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------- #
#                         1. Конфигурация из ENV                               #
# ---------------------------------------------------------------------------- #
IMAGES_DIR="${IMAGES_DIR:-/opt/offline-images}"
MODE="${MODE:-safe}"  # safe | force
CRANE_FLAGS="--insecure"  # Разрешаем HTTP

echo "Starting offline registry initialization (crane-only)..."
echo "   Mode: ${MODE}"
echo "   Registry: ${REGISTRY_URL}"
echo "   Images Dir: ${IMAGES_DIR}"

# ---------------------------------------------------------------------------- #
#                         2. Проверка доступности registry                     #
# ---------------------------------------------------------------------------- #
wait_for_registry() {
    local max_attempts=60
    local attempt=0
    local url="http://${REGISTRY_URL}/v2/"

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

    echo "Found ${#archives[@]} archive(s) to process"

    for arch in "${archives[@]}"; do
        echo
        echo "=== Processing ${arch} ==="

        # Распаковываем во временный файл (crane требует путь к файлу)
        TEMP_TAR="/tmp/image-$$.tar"
        trap "rm -f ${TEMP_TAR}" EXIT
        gunzip -c "${arch}" > "${TEMP_TAR}"

        # Извлекаем имя образа из манифеста архива
        # Используем crane для чтения метаданных
        IMAGE_REF=""

        # Пробуем извлечь из labels в конфиге образа
        local config_blob
        config_blob=$(crane blob "${TEMP_TAR}" $(crane manifest "${TEMP_TAR}" | jq -r '.config.digest') 2>/dev/null) || true

        if [[ -n "${config_blob}" ]]; then
            IMAGE_REF=$(echo "${config_blob}" | jq -r '.config.Labels."org.opencontainers.image.ref.name"' 2>/dev/null) || true
        fi

        # Если не нашли в метаданных — парсим из имени файла
        if [[ -z "${IMAGE_REF}" || "${IMAGE_REF}" == "null" ]]; then
            # Ожидаем формат: имя-образа-тег.tar.gz → имя-образа:тег
            local basename_no_ext
            basename_no_ext=$(basename "${arch}" .tar.gz)

            # Если есть последняя точка после имени — считаем это тегом
            if [[ "${basename_no_ext}" =~ ^(.+)--(.+)$ ]]; then
                IMAGE_REF="${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
            else
                # Fallback: добавляем тег latest
                IMAGE_REF="${basename_no_ext}:latest"
            fi
            echo "Using derived image ref: ${IMAGE_REF}"
        fi

        TARGET_IMAGE="${REGISTRY_URL}/${IMAGE_REF}"
        echo "Image ref: ${IMAGE_REF}"
        echo "   Target: ${TARGET_IMAGE}"

        # Проверка существования в registry
        if [[ "${MODE}" == "force" ]]; then
            if crane digest "${CRANE_FLAGS}" "${TARGET_IMAGE}" >/dev/null 2>&1; then
                echo "Image exists in registry, deleting before re-push (force mode)..."
                crane delete "${CRANE_FLAGS}" "${TARGET_IMAGE}" 2>/dev/null || true
            fi
        else
            if crane digest "${CRANE_FLAGS}" "${TARGET_IMAGE}" >/dev/null 2>&1; then
                echo "Image already exists in registry, skipping (safe mode)."
                rm -f "${TEMP_TAR}"
                continue
            fi
        fi

        # Пуш в реестр
        echo "Pushing ${TARGET_IMAGE} ..."
        crane push "${CRANE_FLAGS}" "${TEMP_TAR}" "${TARGET_IMAGE}"

        echo "Successfully pushed ${TARGET_IMAGE}"

        # Очистка
        rm -f "${TEMP_TAR}"
    done
}

# ---------------------------------------------------------------------------- #
#                         5. Основной поток                                    #
# ---------------------------------------------------------------------------- #
wait_for_registry
process_archives

echo
echo "All images processed successfully!"
