#!/bin/bash

IMAGE_TAG="python:3.10.21-slim-trixie-k5"

docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
