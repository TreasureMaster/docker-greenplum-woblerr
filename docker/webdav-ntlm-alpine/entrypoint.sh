#!/bin/bash
set -e

# Проверяем, переданы ли переменные
if [ -z "$NTLM_USER" ] || [ -z "$NTLM_PASSWORD" ]; then
    echo "[ERROR]: Переменные NTLM_USER и NTLM_PASSWORD должны быть заданы!"
    exit 1
fi

echo "[INFO]: Настройка пользователя $NTLM_USER для NTLM..."

# 1. Создаем пользователя в Linux (без домашней директории и возможности зайти по SSH)
# Устанавливаем системный пароль
# Добавляем пользователя в Samba
# smbpasswd есть в samba-client / samba-common-bin в зависимости от образа
if ! id "$NTLM_USER" &>/dev/null; then
    adduser -D -H -s /sbin/nologin "$NTLM_USER"
    echo "[INFO]: Пользователь настроен успешно."
else
    echo "[INFO]: Пользователь "$NTLM_USER" уже существует."
fi

# ОБЯЗАТЕЛЬНО вне условия: обновляем пароли при КАЖДОМ старте контейнера
echo "${NTLM_USER}:${NTLM_PASSWORD}" | chpasswd
printf "%s\n%s\n" "$NTLM_PASSWORD" "$NTLM_PASSWORD" | smbpasswd -a -s "$NTLM_USER"
echo "[INFO]: Пароли в системе и Samba успешно обновлены."

# 2. Готовим среду для webdav
mkdir -p /var/www/webdav /var/lib/dav /run/apache2 /var/log/apache2
touch /var/lib/dav/DavLock
chown -R apache:apache /var/www/webdav /var/lib/dav || true

# 3. Обеспечиваем права на winbindd_privileged для Apache (UID/GID 82)
mkdir -p /var/lib/samba/winbindd_privileged /var/run/samba
chown root:apache /var/lib/samba/private/msg.sock 2>/dev/null || true
chmod 750 /var/lib/samba/private/msg.sock 2>/dev/null || true
chown -R root:apache /var/lib/samba/winbindd_privileged 2>/dev/null || true
chmod 750 /var/lib/samba/winbindd_privileged 2>/dev/null || true

# 4. Создаем папки для s2t
mkdir -p "/var/www/webdav/information/DocLib/S2T/Актуальные/S2T_RDV/Files"
mkdir -p "/var/www/webdav/information/DocLib/S2T/Актуальные/S2T_STG/Files"
mkdir -p "/var/www/webdav/information/DocLib/Логическая модель BDV/Актуальная"
chown -R 82:82 /var/www/webdav
chmod -R 775 /var/www/webdav

# 5. Очистка PID и временных файлов перед стартом
# rm -f /var/run/samba/winbindd.pid
# rm -f /var/run/winbindd.pid
# rm -f /var/lib/samba/winbindd_privileged/pipe
# rm -f /var/run/samba/winbindd.sock
# rm -rf /var/run/samba/msg.lock/
# Грубая очистка ВСЕХ временных файлов, PID и блокировок Samba.
rm -rf /var/run/samba/*
rm -rf /var/cache/samba/*

# 6. Запускаем winbind БЕЗ флага -D.
echo "[INFO]: Запуск Winbind..."
winbindd -D
# winbindd -F --no-process-group &

# Даем winbind 2 секунды, чтобы он гарантированно успел создать сокеты
# до того, как Apache начнет выполнять проверки ntlm_auth
sleep 2

echo "[INFO]: Запуск Apache..."
# 6. Запускаем Apache на переднем плане (стандартная команда)
exec httpd -D FOREGROUND
