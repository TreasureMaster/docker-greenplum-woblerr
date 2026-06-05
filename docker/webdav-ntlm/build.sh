#!/bin/bash

IMAGE_TAG="webdav-ntlm:0.0.1-debian12-k1"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
