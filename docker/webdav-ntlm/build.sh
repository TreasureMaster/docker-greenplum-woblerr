#!/bin/bash

IMAGE_TAG="webdav-ntlm:0.0.2-debian12"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
