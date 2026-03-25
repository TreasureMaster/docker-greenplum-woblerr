FROM docker:26.1.4-cli

# Устанавливаем curl и опционально crane
RUN apk add --no-cache curl

# Загружаем crane (опционально, можно закомментировать)
ARG CRANE_VERSION=v0.21.3
# RUN if [ "${CRANE_ENABLED:-false}" = "true" ]; then \
RUN wget -q https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz \
    && tar xzf go-containerregistry_Linux_x86_64.tar.gz -C /usr/local/bin crane \
    && rm go-containerregistry_Linux_x86_64.tar.gz
    # fi

COPY init-entrypoint.sh /init-entrypoint.sh
RUN chmod +x /init-entrypoint.sh /usr/local/bin/crane

COPY images/ /opt/offline-images/

ENTRYPOINT ["/init-entrypoint.sh"]
