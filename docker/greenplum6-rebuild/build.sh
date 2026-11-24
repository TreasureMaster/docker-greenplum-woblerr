#!/bin/bash

IMAGE_TAG="treasuremaster/greenplum:6.27.1-redos7-t4"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
