FROM jenkins/jenkins:2.516.3-lts

# Установка Docker
USER root
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# RUN mkdir -p /etc/apt/keyrings && \
#     curl -fsSL https://docker.com | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://docker.com $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

RUN echo "Types: deb\n\
URIs: https://download.docker.com/linux/debian\n\
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")\n\
Components: stable\n\
Architectures: $(dpkg --print-architecture)\n\
Signed-By: /etc/apt/keyrings/docker.asc" > /etc/apt/sources.list.d/docker.sources

ARG DOCKER_CLI_VERSION="5:26.1.4-1~debian-bookworm"

RUN apt-get update && apt-get install -y \
    docker-ce-cli=${DOCKER_CLI_VERSION}
    # docker-buildx-plugin \
    # docker-compose-plugin

# RUN groupadd -g 999 docker || true && \
RUN usermod -aG docker jenkins

USER jenkins

# Отключаем мастер настройки, так как мы ставим всё заранее
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Установка плагинов jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

# Файлы инициализации jenkins
COPY --chown=jenkins:jenkins jenkins.yaml /var/jenkins_home/jenkins.yaml
COPY --chown=jenkins:jenkins ./init.groovy.d/01-basic-init.groovy /usr/share/jenkins/ref/init.groovy.d/01-basic-init.groovy
