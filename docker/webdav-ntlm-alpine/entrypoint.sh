#!/bin/bash
set -e

# Проверяем, переданы ли обязательные переменные окружения
if [ -z "$NTLM_USER" ] || [ -z "$NTLM_PASSWORD" ]; then
    echo "[ERROR]: Переменные NTLM_USER и NTLM_PASSWORD должны быть заданы!"
    exit 1
fi

echo "[INFO]: Настройка пользователя $NTLM_USER для NTLM..."

# 1. Создаем локального пользователя, если он еще не существует
if ! id "$NTLM_USER" &>/dev/null; then
    adduser -D -H -s /sbin/nologin "$NTLM_USER"
    echo "[INFO]: Пользователь успешно создан в системе."
else
    echo "[INFO]: Пользователь $NTLM_USER уже существует."
fi

# Актуализируем пароли в системе и Samba при КАЖДОМ старте контейнера
echo "${NTLM_USER}:${NTLM_PASSWORD}" | chpasswd
printf "%s\n%s\n" "$NTLM_PASSWORD" "$NTLM_PASSWORD" | smbpasswd -a -s "$NTLM_USER"
echo "[INFO]: Пароли в системе и Samba успешно обновлены."

# 2. Готовим базовую среду для Apache и WebDAV
mkdir -p /var/www/webdav /var/lib/dav /run/apache2 /var/log/apache2 /var/run/samba
touch /var/lib/dav/DavLock
chown -R apache:apache /var/www/webdav /var/lib/dav

# 3. Создаем целевую структуру папок для s2t карт
mkdir -p "/var/www/webdav/information/DocLib/S2T/Актуальные/S2T_RDV/Files"
mkdir -p "/var/www/webdav/information/DocLib/S2T/Актуальные/S2T_STG/Files"
mkdir -p "/var/www/webdav/information/DocLib/Логическая модель BDV/Актуальная"
chown -R 82:82 /var/www/webdav
chmod -R 775 /var/www/webdav

# 4. 🔥 КРИТИЧЕСКИЙ ФИКС БЕЗОПАСНОСТИ И ОЧИСТКА ХВОСТОВ ПЕРЕД РЕСТАРТОМ
echo "[INFO]: Очистка временных файлов, старых PID и сокетов Samba..."
# Удаляем старые PID-файлы, которые могли остаться при некорректном stop/kill контейнера
rm -f /var/run/samba/*.pid /var/run/*.pid

# Удаляем старую папку IPC-сообщений, чтобы winbindd воссоздал её строго с правами 0700
rm -rf /var/lib/samba/private/msg.sock
rm -rf /var/run/samba/msg.lock

# Настраиваем права группы apache (UID/GID 82) строго на директорию привилегированных пайпов.
# Этого на 100% достаточно, чтобы ntlm_auth из-под веб-сервера мог беспрепятственно общаться с winbind.
mkdir -p /var/lib/samba/winbindd_privileged
rm -f /var/lib/samba/winbindd_privileged/pipe
chown -R root:apache /var/lib/samba/winbindd_privileged
chmod 750 /var/lib/samba/winbindd_privileged

# 5. Передаем управление Supervisor для параллельного контроля winbindd и httpd
echo "[INFO]: Запуск Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
