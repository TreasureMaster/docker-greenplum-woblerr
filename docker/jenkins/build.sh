#!/bin/bash

IMAGE_TAG="jenkins/jenkins:2.516.3-lts-plg4"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
