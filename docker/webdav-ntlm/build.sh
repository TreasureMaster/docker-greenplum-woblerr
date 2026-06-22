#!/bin/bash

IMAGE_TAG="dwh/webdav-ntlm:0.0.4"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
