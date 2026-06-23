#!/bin/bash

IMAGE_TAG="dwh/webdav-ntlm:0.0.9-alpine"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
