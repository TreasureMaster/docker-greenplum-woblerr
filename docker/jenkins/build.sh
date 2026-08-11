#!/bin/bash

IMAGE_TAG="treasuremaster/jenkins:2.516.3-lts-plg7.21"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
