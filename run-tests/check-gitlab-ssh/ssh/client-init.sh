#!/usr/bin/env bash
set -euo pipefail

echo "[dwh-init] installing ssh client..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-client netcat-traditional

echo "[dwh-init] generating SSH key in shared volume..."
mkdir -p /shared-ssh
if [[ ! -f /shared-ssh/id_ed25519 ]]; then
  ssh-keygen -t ed25519 -N "" -f /shared-ssh/id_ed25519
fi
chmod 600 /shared-ssh/id_ed25519

echo "[dwh-init] waiting for gitlab SSH (port 22)..."
# gitlab доступен по hostname ${GITLAB_HOSTNAME}, но внутри сети проще использовать имя сервиса "gitlab"
until nc -z gitlab 22 >/dev/null 2>&1; do
  echo "[dwh-init] gitlab:22 not ready, sleeping 5s..."
  sleep 5
done

echo "[dwh-init] trying ssh gitlab-rails version..."

SSH_OPTS="-i /shared-ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

ssh ${SSH_OPTS} root@${GITLAB_HOSTNAME} "ls -la /" || echo "[dwh-init] ssh command failed"

ssh ${SSH_OPTS} root@${GITLAB_HOSTNAME} \
  "gitlab-rails runner 'puts Gitlab::VERSION'" || echo "[dwh-init] ssh/gitlab-rails failed"

echo "[dwh-init] SSH test finished."
