#!/bin/bash
set -e

# Проверяем, переданы ли переменные
if [ -z "$NTLM_USER" ] || [ -z "$NTLM_PASSWORD" ]; then
    echo "Ошибка: Переменные NTLM_USER и NTLM_PASSWORD должны быть заданы!"
    exit 1
fi

echo "Настройка пользователя $NTLM_USER для NTLM..."

# 1. Создаем пользователя в Linux (без домашней директории и возможности зайти по SSH)
if ! id "$NTLM_USER" &>/dev/null; then
    useradd -M -s /usr/sbin/nologin "$NTLM_USER"
fi

# 2. Задаем ему системный пароль и пароль для Samba/Swinbind (NTLM)
echo -e "$NTLM_PASSWORD\n$NTLM_PASSWORD" | passwd "$NTLM_USER"
echo -e "$NTLM_PASSWORD\n$NTLM_PASSWORD" | smbpasswd -a -s "$NTLM_USER"

# 3. Даем Apache (www-data) права на выполнение проверок через ntlm_auth
chown root:www-data /var/lib/samba/private/msg.sock 2>/dev/null || true
chmod 750 /var/lib/samba/private/msg.sock 2>/dev/null || true

echo "Пользователь настроен успешно. Запуск Apache..."

# Запускаем Apache на переднем плане (стандартная команда)
exec apachectl -D FOREGROUND
