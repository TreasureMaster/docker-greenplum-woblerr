#!/bin/bash

IMAGE_TAG="jenkins/jenkins:2.516.3-lts-plg7.12"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
