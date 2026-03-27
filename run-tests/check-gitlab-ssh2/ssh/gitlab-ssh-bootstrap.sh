#!/usr/bin/env bash
set -euo pipefail

GITLAB_HOST="${GITLAB_HOSTNAME:-gitlab}"   # из .env
GITLAB_SSH_PORT="${GITLAB_SSH_PORT:-22}"   # можешь задать в env
GITLAB_ROOT_PASSWORD="${INITIAL_ROOT_PASSWORD}"  # важно прокинуть в dwh-init

echo "[dwh-init] installing ssh client..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-client sshpass netcat-traditional

echo "[dwh-init] generating SSH key in shared volume..."
mkdir -p /shared-ssh
if [[ ! -f /shared-ssh/id_ed25519 ]]; then
  ssh-keygen -t ed25519 -N "" -f /shared-ssh/id_ed25519
fi
chmod 600 /shared-ssh/id_ed25519

echo "[dwh-init] waiting for gitlab SSH (${GITLAB_HOST}:${GITLAB_SSH_PORT})..."
until nc -z "${GITLAB_HOST}" "${GITLAB_SSH_PORT}" >/dev/null 2>&1; do
  echo "[dwh-init] gitlab SSH not ready, sleeping 5s..."
  sleep 5
done

SSH_OPTS="-p ${GITLAB_SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "[dwh-init] installing public key on gitlab via password login..."
sshpass -p "${GITLAB_ROOT_PASSWORD}" ssh ${SSH_OPTS} root@"${GITLAB_HOST}" "mkdir -p /root/.ssh && chmod 700 /root/.ssh"
sshpass -p "${GITLAB_ROOT_PASSWORD}" ssh ${SSH_OPTS} root@"${GITLAB_HOST}" "grep -qxF \"$(cat /shared-ssh/id_ed25519.pub)\" /root/.ssh/authorized_keys 2>/dev/null || echo \"$(cat /shared-ssh/id_ed25519.pub)\" >> /root/.ssh/authorized_keys"
sshpass -p "${GITLAB_ROOT_PASSWORD}" ssh ${SSH_OPTS} root@"${GITLAB_HOST}" "chmod 600 /root/.ssh/authorized_keys"

echo "[dwh-init] testing login with key..."
ssh ${SSH_OPTS} -i /shared-ssh/id_ed25519 root@"${GITLAB_HOST}" "gitlab-rails runner 'puts Gitlab::VERSION'" || echo "[dwh-init] ssh/gitlab-rails failed"

echo "[dwh-init] SSH bootstrap finished."
