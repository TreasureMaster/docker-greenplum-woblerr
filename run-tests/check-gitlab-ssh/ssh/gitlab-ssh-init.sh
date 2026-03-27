#!/usr/bin/env bash
set -euo pipefail

echo "[gitlab-init] configuring SSH access for root..."

# ждём появления публичного ключа от dwh-init (опционально)
if [[ ! -f /shared-ssh/id_ed25519.pub ]]; then
  echo "[gitlab-init] /shared-ssh/id_ed25519.pub not found yet, will not add key."
  exit 0
fi

mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys

if ! grep -q "$(cat /shared-ssh/id_ed25519.pub)" /root/.ssh/authorized_keys 2>/dev/null; then
  echo "[gitlab-init] adding client public key to /root/.ssh/authorized_keys"
  cat /shared-ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
fi

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

echo "[gitlab-init] SSH access prepared."
