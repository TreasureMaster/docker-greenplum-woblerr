#!/bin/bash

IMAGE_TAG="dwh-init:0.3.2"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
