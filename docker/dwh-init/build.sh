#!/bin/bash
set -euo pipefail

VERSION="1.0.0"
IMAGE_TAG="dwh-init:${VERSION}"

OUTPUT_DIR="$HOME/images"
OUTPUT_FILE="${OUTPUT_DIR}/dwh-init--${VERSION}.tar.gz"


# Собираем образ
docker build --progress=plain -t "$IMAGE_TAG" .

# Создаём каталог для архивов, если его ещё нет
mkdir -p "$OUTPUT_DIR"

# Сохраняем образ в tar.gz
docker save "$IMAGE_TAG" | gzip > "$OUTPUT_FILE"

echo "Образ $IMAGE_TAG сохранён в архив: $OUTPUT_FILE"
