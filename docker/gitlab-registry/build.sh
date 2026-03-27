#!/bin/bash

IMAGE_TAG="dwh-init:0.3.5"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
