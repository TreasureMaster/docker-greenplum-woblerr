# FROM docker:26.1.4-cli
FROM alpine:3.22.3

# Устанавливаем curl и опционально crane
RUN apk update && apk add --no-cache curl bash gzip jq yq

# Загружаем crane (опционально, можно закомментировать)
ARG CRANE_VERSION=v0.21.3
# RUN if [ "${CRANE_ENABLED:-false}" = "true" ]; then \
RUN wget -q https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz \
    && tar xzf go-containerregistry_Linux_x86_64.tar.gz -C /usr/local/bin crane \
    && rm go-containerregistry_Linux_x86_64.tar.gz
    # fi

# COPY registry-init.sh /registry-init.sh
# COPY run-dwh.sh /run-dwh.sh
RUN mkdir -p /init
COPY *.sh /init/
RUN chmod -R +x /init /usr/local/bin/crane
# RUN chmod +x /registry-init.sh /run-dwh.sh /usr/local/bin/crane

COPY images/ /opt/offline-images/
WORKDIR /init

# ENTRYPOINT ["/init-entrypoint.sh"]
ENTRYPOINT ["./run-dwh.sh"]
