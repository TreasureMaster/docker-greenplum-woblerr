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
    # useradd -M -s /usr/sbin/nologin "$NTLM_USER"
    adduser -D -H -s /sbin/nologin "$NTLM_USER"
fi

# 2. Задаем ему системный пароль и пароль для Samba/Swinbind (NTLM)
# echo -e "$NTLM_PASSWORD\n$NTLM_PASSWORD" | passwd "$NTLM_USER"
# echo -e "$NTLM_PASSWORD\n$NTLM_PASSWORD" | smbpasswd -a -s "$NTLM_USER"

# Устанавливаем системный пароль
echo "${NTLM_USER}:${NTLM_PASSWORD}" | chpasswd

# Добавляем пользователя в Samba
# smbpasswd есть в samba-client / samba-common-bin в зависимости от образа
printf "%s\n%s\n" "$NTLM_PASSWORD" "$NTLM_PASSWORD" | smbpasswd -a -s "$NTLM_USER"

mkdir -p /var/www/webdav /var/lib/dav /run/apache2 /var/log/apache2
touch /var/lib/dav/DavLock
chown -R apache:apache /var/www/webdav /var/lib/dav || true

# 3. Даем Apache (www-data) права на выполнение проверок через ntlm_auth
chown root:www-data /var/lib/samba/private/msg.sock 2>/dev/null || true
chmod 750 /var/lib/samba/private/msg.sock 2>/dev/null || true
# Обязательно даем права на winbindd_privileged для корректной работы ntlm_auth от www-data
# chown -R root:www-data /var/lib/samba/winbindd_privileged 2>/dev/null || true
# chmod 750 /var/lib/samba/winbindd_privileged 2>/dev/null || true

# Запускаем winbind в фоновом режиме, он жизненно необходим для ntlm_auth
# winbindd -D

echo "Пользователь настроен успешно. Запуск Apache..."
# Запускаем Apache на переднем плане (стандартная команда)
exec apachectl -D FOREGROUND
