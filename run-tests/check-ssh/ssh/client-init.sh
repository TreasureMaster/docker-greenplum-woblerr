#!/usr/bin/env bash
set -euo pipefail

echo "[client] installing ssh client..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-client

echo "[client] generating SSH key..."
mkdir -p /shared-ssh
if [[ ! -f /shared-ssh/id_ed25519 ]]; then
  ssh-keygen -t ed25519 -N "" -f /shared-ssh/id_ed25519
fi
chmod 600 /shared-ssh/id_ed25519

echo "[client] waiting for ssh-server:22..."
until nc -z ssh-server 22 >/dev/null 2>&1; do
  echo "[client] ssh-server not ready, sleeping 2s..."
  sleep 2
done

echo "[client] trying ssh ls -la / on ssh-server..."
SSH_OPTS="-i /shared-ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

ssh ${SSH_OPTS} root@ssh-server "ls -la /" || echo "[client] ssh command failed"

echo "[client] done, going to sleep."
