ARG REPO_BUILD_TAG
ARG OL_VERSION="8"
ARG GOLANG_VERSION="1.24.11"
ARG GPXERCES_DOWNLOAD_URL="https://github.com/woblerr/gp-xerces/archive/refs/tags"
ARG GPXERCES_VERSION="v3.1.2-p1"
ARG LIBSIGAR_DOWNLOAD_URL="https://github.com/boundary/sigar"
ARG LIBSIGAR_COMMIT_HASH="e8961a6674cc4d292e61b353b5c36bfc345434cc"
ARG GPDB_DOWNLOAD_URL="https://github.com/woblerr/gpdb/archive/refs/tags"
ARG GPDB_VERSION="6.27.1"
ARG DISKQUOTA_DOWNLOAD_URL="https://github.com/woblerr/diskquota/archive/refs/tags"
ARG DISKQUOTA_VERSION="2.3.0"
ARG PXF_DOWNLOAD_URL="https://github.com/woblerr/pxf/archive/refs/tags"
ARG PXF_VERSION="release-6.10.1"
ARG GPBACKUP_DOWNLOAD_URL="https://github.com/woblerr/gpbackup/archive/refs/tags"
ARG GPBACKUP_VERSION="1.30.5"
ARG GPBACKUP_S3_PLUGIN_DOWNLOAD_URL="https://github.com/woblerr/gpbackup-s3-plugin/archive/refs/tags"
ARG GPBACKUP_S3_PLUGIN_VERSION="1.10.2"
ARG GPBACKMAN_DOWNLOAD_URL="https://github.com/woblerr/gpbackman/archive/refs/tags"
ARG GPBACKMAN_VERSION="v0.8.1"
ARG WALG_DOWNLOAD_URL="https://github.com/wal-g/wal-g"
# Wait new WAL-G release
ARG WALG_VERSION="4b33c88939ce0cc23acc5f89dcf5e427c50923d9"
ARG GOSU_VERSION="1.19"

FROM oraclelinux:${OL_VERSION}

ARG REPO_BUILD_TAG
ARG GPDB_VERSION
ARG GOSU_VERSION

ENV TZ="Etc/UTC" \
    GREENPLUM_USER="gpadmin" \
    GREENPLUM_UID=1001 \
    GREENPLUM_GROUP="gpadmin" \
    GREENPLUM_GID=1001 \
    GREENPLUM_DEPLOYMENT="singlenode" \
    GREENPLUM_DATA_DIRECTORY="/data" \
    GREENPLUM_SEG_PREFIX="gpseg" \
    GREENPLUM_DATABASE_NAME="demo" \
    GREENPLUM_GPPERFMON_ENABLE="false" \
    GREENPLUM_DISKQUOTA_ENABLE="false" \
    GREENPLUM_PXF_ENABLE="false" \
    GREENPLUM_WALG_ENABLE="false"

# Install runtime dependencies
RUN dnf -y update \
    && dnf -y install \
        apr \
        apr-util \
        bzip2-libs \
        libcurl \
        libevent \
        krb5-libs \
        pam \
        readline \
        openssl-libs \
        libuv \
        libxml2 \
        libyaml \
        libzstd \
        zlib \
        openldap \
        iputils \
        krb5-server \
        krb5-workstation \
        libuuid \
        openssh-clients \
        openssh-server \
        openssl \
        binutils \
        perl \
        rsync \
        curl \
        sed \
        tar \
        zip \
        net-tools \
        less \
        glibc-langpack-en \
        glibc-locale-source \
        iproute \
        python2 \
        sudo \
        wget \
        hostname \
        ca-certificates \
        tzdata \
        java-11-openjdk-headless \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
# https://github.com/tianon/gosu/blob/master/INSTALL.md
RUN arch="$(uname -m)" \
    && case "${arch}" in \
            aarch64) dpkgArch='arm64' ;; \
            x86_64) dpkgArch='amd64' ;; \
            *) echo >&2 "error: unknown/unsupported architecture '${arch}'"; exit 1 ;; \
        esac \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}.asc" \
    # Verify the signature
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    # Verify that the binary works
    && gosu --version \
    && gosu nobody true

RUN groupadd --gid ${GREENPLUM_GID} ${GREENPLUM_GROUP} \
    && useradd --shell /bin/bash --uid ${GREENPLUM_UID} --gid ${GREENPLUM_GID} -m ${GREENPLUM_USER} \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && mkdir -m 700 -p /home/${GREENPLUM_USER}/.ssh \
    && ssh-keygen -f /home/${GREENPLUM_USER}/.ssh/id_rsa -t rsa -N "" \
    && echo "HostKeyAlgorithms +ssh-rsa" >> /etc/ssh/sshd_config \
    && echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/sshd_config \
    && echo "${GREENPLUM_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && echo "source /usr/local/greenplum-db/greenplum_path.sh" > /home/${GREENPLUM_USER}/.bashrc \
    && echo "export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk" >> /home/${GREENPLUM_USER}/.bashrc \
    && echo 'export PATH="/usr/local/pxf/bin:${PATH}"' >> /home/${GREENPLUM_USER}/.bashrc \
    && echo "export PXF_BASE=${GREENPLUM_DATA_DIRECTORY}/pxf" >> /home/${GREENPLUM_USER}/.bashrc \
    && mkdir -p ${GREENPLUM_DATA_DIRECTORY} \
                ${GREENPLUM_DATA_DIRECTORY}/pxf \
                /docker-entrypoint-initdb.d \
    && chown -R ${GREENPLUM_USER}:${GREENPLUM_GROUP} \
        /home/${GREENPLUM_USER}/ \
        ${GREENPLUM_DATA_DIRECTORY} \
        /docker-entrypoint-initdb.d \
    && ln -s /usr/bin/python2 /usr/bin/python \
    && unlink /etc/localtime \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

# COPY --from=go_builder /usr/local/greenplum-db /usr/local/greenplum-db
# COPY --from=builder \
#     /usr/local/lib/libxerces-c.so \ 
#     /usr/local/lib/libxerces-c-3.1.so \
#     /usr/local/lib/libsigar.so \
#     /usr/local/greenplum-db/lib/
# COPY --from=go_builder \
#     /opt/go/bin/gpbackup \
#     /opt/go/bin/gprestore \
#     /opt/go/bin/gpbackup_helper \
#     /usr/local/greenplum-db/bin/
# COPY --from=go_builder /opt/go/bin/gpbackup_s3_plugin /usr/local/greenplum-db/bin/gpbackup_s3_plugin
# COPY --from=go_builder /usr/local/pxf /usr/local/pxf
# COPY --from=go_builder /tmp/gpbackman/gpbackman /usr/local/greenplum-db/bin/gpbackman
# COPY --from=go_builder /tmp/wal-g/main/gp/wal-g /usr/local/greenplum-db/bin/wal-g
# COPY --chmod=750 docker/files/entrypoint.sh /entrypoint.sh
# COPY --chmod=750 docker/files/start_gpdb.sh /start_gpdb.sh
COPY --chmod=750 docker/files/*.sh /

# LABEL \
#     org.opencontainers.image.version="${REPO_BUILD_TAG}" \
#     org.opencontainers.image.source="https://github.com/woblerr/docker-greenplum"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start_gpdb.sh"]
