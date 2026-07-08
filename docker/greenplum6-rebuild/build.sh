#!/bin/bash

IMAGE_TAG="treasuremaster/greenplum:6.27.1-oraclelinux8-t3"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
