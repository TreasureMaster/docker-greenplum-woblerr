#!/bin/bash

IMAGE_TAG="dwh/webdav-ntlm:0.0.5-alpine"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
