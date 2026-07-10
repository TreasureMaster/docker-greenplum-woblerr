FROM alpine:3.23.5

# ENV TZ=Europe/Moscow

RUN apk add --no-cache \
    apache2 \
    apache2-webdav \
    apache-mod-auth-ntlm-winbind \
    # ДОБАВЛЯЕМ ДРАЙВЕРЫ ДЛЯ БАЗЫ БЛОКИРОВОК WEBDAV
    # apr-util-dbd \
    # apr-util-dbd_sqlite3 \
    gdbm \
    apr-util-dbm_gdbm \
    samba \
    samba-winbind \
    samba-winbind-clients \
    bash \
    curl \
    ca-certificates \
    tzdata \
    supervisor

RUN mkdir -p /var/www/webdav \
    /var/lib/dav \
    /run/apache2 \
    /var/log/apache2 \
    /etc/supervisor.d

# Включаем модули Apache
RUN sed -i 's/^#LoadModule dav_module/LoadModule dav_module/' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule dav_fs_module/LoadModule dav_fs_module/' /etc/apache2/httpd.conf || true
    # sed -i '/DavLockDB/i DBMType gdbm' /etc/apache2/conf.d/dav.conf || true

# Подключаем свой конфиг
# COPY httpd.conf /etc/apache2/httpd.conf
COPY webdav-ntlm.conf /etc/apache2/conf.d/webdav-ntlm.conf
COPY smb.conf /etc/samba/smb.conf
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# VOLUME ["/var/www/webdav", "/var/lib/dav"]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]