#!/usr/bin/env bash
set -euo pipefail

echo "[DEBUG]: get root token..."
ROOT_TOKEN=$(cat /shared/bootstrap/root_pat.txt 2>/dev/null || true)
if [ -z "${ROOT_TOKEN}" ]; then
  echo "ROOT PAT not found in /shared/bootstrap/root_pat.txt" >&2
  # exit 1
else
  echo "ROOT PAT: ${ROOT_TOKEN}"
fi
