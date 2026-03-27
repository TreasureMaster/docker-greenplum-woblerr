#!/usr/bin/env bash
set -euo pipefail

while [[ ! -f /shared/bootstrap/root_pat.txt ]]; do
  echo "[gitlab-init] /shared/bootstrap/root_pat.txt not found yet, waiting 10 seconds..."
  sleep 10
done

echo "[gitlab-init] Found /shared/bootstrap/root_pat.txt, proceeding..."

echo "[DEBUG]: get root token..."
ROOT_TOKEN=$(cat /shared/bootstrap/root_pat.txt 2>/dev/null || true)
if [ -z "${ROOT_TOKEN}" ]; then
  echo "ROOT PAT not found in /shared/bootstrap/root_pat.txt" >&2
  # exit 1
else
  echo "ROOT PAT: ${ROOT_TOKEN}"
fi
