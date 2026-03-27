FROM jenkins/jenkins:2.516.3-lts

# Отключаем мастер настройки, так как мы ставим всё заранее
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins jenkins.yaml /var/jenkins_home/jenkins.yaml
COPY --chown=jenkins:jenkins ./init.groovy.d/01-basic-init.groovy /usr/share/jenkins/ref/init.groovy.d/01-basic-init.groovy
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt
