#!/bin/bash

IMAGE_TAG="python:3.10.20-slim-bookworm-k2"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
