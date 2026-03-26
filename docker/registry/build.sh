#!/bin/bash

IMAGE_TAG="dwh-init:0.1.0-cli"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
