FROM bitnami-airflow:2.9.3-debian-12-r11-t11

# 1. Установка gosu (пример для Debian-based, для Alpine замените на apk add)
USER root

# Добавляем tini, gnupg
RUN apt-get update \
    && apt-get install -y --no-install-recommends tini gnupg \
    && rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.19
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget; \
    rm -rf /var/lib/apt/lists/*; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    # gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

# --- SSH server (OpenSSH) ---
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends openssh-server openssh-client; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /var/run/sshd; \
    ssh-keygen -A; \
    # базовая настройка авторизации по паролю
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config; \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config; \
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config


# RUN apt-get update \
#     && apt-get install -y --no-install-recommends gosu openssh-server \
#     && rm -rf /var/lib/apt/lists/*

# 2. Копируем preinit-скрипт
RUN mkdir /docker-entrypoint-preinit.d
COPY --chmod=0755 preinit-entrypoint.sh /usr/local/bin/

# 3. Переопределяем ENTRYPOINT (CMD оставляем стандартным)
# ENTRYPOINT ["/usr/local/bin/preinit-entrypoint.sh"]
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/preinit-entrypoint.sh"]
CMD ["/opt/bitnami/scripts/airflow/run.sh"]
