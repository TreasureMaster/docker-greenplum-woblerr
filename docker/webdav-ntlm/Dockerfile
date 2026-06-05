FROM debian:12-slim

# Отключаем интерактивные диалоги apt
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем Apache, модуль NTLM и утилиты для работы с паролями
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-auth-ntlm-winbind \
    apache2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Включаем модули WebDAV в конфигурации Apache
RUN a2enmod dav && a2enmod dav_fs

# Создаем директории для файлов и базы блокировок WebDAV
RUN mkdir -p /var/www/webdav /var/lib/dav \
    && chown -R www-data:www-data /var/www/webdav /var/lib/dav

# Создаем пользователя "jenkins" с паролем "password123" для requests-ntlm
RUN htpasswd -b -c /etc/apache2/.htpasswd jenkins password123

# Перенаправляем логи Apache в stdout/stderr, чтобы их можно было смотреть через `docker logs`
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

# Запуск Apache на переднем плане
CMD ["apachectl", "-D", "FOREGROUND"]
