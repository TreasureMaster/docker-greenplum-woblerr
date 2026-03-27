#!/usr/bin/env bash
set -euo pipefail

echo "[server] installing openssh-server..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-server

echo "[server] configuring sshd..."
mkdir -p /var/run/sshd

sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys

if [[ -f /shared-ssh/id_ed25519.pub ]]; then
  echo "[server] adding client public key to authorized_keys..."
  cat /shared-ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
fi

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

echo "[server] starting sshd..."
/usr/sbin/sshd -D &

echo "[server] ready."
