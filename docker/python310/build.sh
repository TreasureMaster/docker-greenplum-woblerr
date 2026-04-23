#!/bin/bash

IMAGE_TAG="python:3.10.20-slim-bookworm-k1"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
