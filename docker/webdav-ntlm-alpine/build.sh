#!/bin/bash

IMAGE_TAG="treasuremaster/webdav-ntlm:0.1.1-alpine"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
