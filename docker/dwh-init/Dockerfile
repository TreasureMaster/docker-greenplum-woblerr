FROM alpine:3.22.3

# Устанавливаем curl и опционально crane
RUN apk update && apk add --no-cache curl bash gzip jq yq git

# Загружаем crane (опционально, можно закомментировать)
ARG CRANE_VERSION=v0.21.3
RUN wget -q https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz \
    && tar xzf go-containerregistry_Linux_x86_64.tar.gz -C /usr/local/bin crane \
    && rm go-containerregistry_Linux_x86_64.tar.gz

RUN mkdir -p /init
COPY *.sh /init/
RUN chmod -R +x /init /usr/local/bin/crane

COPY images/ /opt/offline-images/
WORKDIR /init
COPY ./gitlab-rails-init/* ./gitlab-rails-init/
COPY ./projects/* ./projects/
COPY ./gpconf/* ./gpconf/
COPY ./gpsecrets/* ./gpsecrets/
COPY ./pxf/ ./pxf/
COPY ./docker-entrypoint-gpinit/ ./docker-entrypoint-gpinit/
COPY ./pg-conf/ ./
COPY ./af-conf/preinit/ ./af-preinit/

ENTRYPOINT ["./run-dwh.sh"]
