#!/bin/bash

IMAGE_TAG="dwh/bitnami-airflow:2.9.3-debian12-r11-t11.ssh"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
# docker build -t "$IMAGE_TAG" .
