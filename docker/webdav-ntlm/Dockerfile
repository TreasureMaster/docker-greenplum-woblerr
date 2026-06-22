FROM debian:12-slim

# Отключаем интерактивные диалоги apt
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем Apache, модуль NTLM и утилиты для работы с паролями
RUN apt-get update && apt-get install -y \
    apache2 \
    # libapache2-mod-dav \
    # libapache2-mod-dav-fs \
    samba-common-bin \
    winbind \
    cifs-utils \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и собираем модуль mod_authn_ntlm для работы с ntlm_auth (Samba)
# RUN git clone https://github.com /tmp/mod_authn_ntlm \
#     && cd /tmp/mod_authn_ntlm \
#     && axs2 -i -a -c mod_authn_ntlm.c \
#     && rm -rf /tmp/mod_authn_ntlm

# Включаем модули WebDAV в конфигурации Apache
# RUN a2enmod dav && a2enmod dav_fs && a2enmod authn_core && a2enmod authz_core && a2enmod authn_ntlm
RUN a2enmod dav dav_fs headers rewrite ssl authn_core auth_basic authz_core

# Если в репозитории есть NTLM-модуль — подключайте его здесь.
# На практике пакет/имя модуля зависят от дистрибутива.
RUN a2enmod auth_ntlm || true

# Создаем директории для файлов и базы блокировок WebDAV
RUN mkdir -p /var/www/webdav /var/lib/dav \
    && chown -R www-data:www-data /var/www/webdav /var/lib/dav

# Создаем пользователя "jenkins" с паролем "password123" для requests-ntlm
# RUN htpasswd -b -c /etc/apache2/.htpasswd jenkins password123

# Перенаправляем логи Apache в stdout/stderr, чтобы их можно было смотреть через `docker logs`
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

# Копируем скрипт инициализации
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

# VOLUME ["/var/www/webdav", "/var/lib/dav"]

# Назначаем скрипт основной точкой запуска контейнера
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Запуск Apache на переднем плане
# CMD ["apachectl", "-D", "FOREGROUND"]
