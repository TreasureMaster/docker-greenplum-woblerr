#!/bin/bash

IMAGE_TAG="treasuremaster/jenkins:2.516.3-lts-plg7.18"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
