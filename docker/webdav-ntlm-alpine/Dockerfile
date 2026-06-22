FROM alpine:3.21

# ENV TZ=Europe/Moscow

RUN apk add --no-cache \
    apache2 \
    apache2-webdav \
    apache2-proxy \
    apache-mod-auth-ntlm-winbind \
    samba \
    samba-client \
    winbind \
    bash \
    ca-certificates \
    tzdata \
    curl

RUN mkdir -p /var/www/webdav \
    /var/lib/dav \
    /run/apache2 \
    /var/log/apache2

# Включаем модули Apache
RUN sed -i 's/^#LoadModule dav_module/LoadModule dav_module/' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule dav_fs_module/LoadModule dav_fs_module/' /etc/apache2/httpd.conf || true

# Подключаем свой конфиг
# COPY httpd.conf /etc/apache2/httpd.conf
# COPY webdav-ntlm.conf /etc/apache2/conf.d/webdav-ntlm.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# VOLUME ["/var/www/webdav", "/var/lib/dav"]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]