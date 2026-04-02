#!/usr/bin/env groovy

import jenkins.model.*
import hudson.security.*
import hudson.util.*

def instance = Jenkins.getInstance()

// Создаём админа
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(
    System.getenv('START_ADMIN_USERNAME') ?: 'admin',
    System.getenv('START_ADMIN_PASSWORD') ?: 'password'
)
instance.setSecurityRealm(hudsonRealm)

// Даём права админа
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// 2. Устанавливаем Jenkins URL
def locationConfig = JenkinsLocationConfiguration.get()
if (locationConfig) {
    String jenkinsUrl = System.getenv('JENKINS_URL') ?: 'http://localhost:8080/'
    locationConfig.setUrl(jenkinsUrl)
    locationConfig.save()
}

// FIXME не работает
// Отключаем проверку обратного прокси
// def jenkins = Jenkins.getInstance()
// def rootUrlFromRequest = instance.getDescriptorByType(
//     jenkins.model.JenkinsLocationConfiguration.class
// ).getClass().getDeclaredField("rootUrlFromRequest")
// rootUrlFromRequest.setAccessible(true)
// rootUrlFromRequest.set(instance.getDescriptorByType(jenkins.model.JenkinsLocationConfiguration.class), false)

// 3. ОТКЛЮЧАЕМ проверку reverse proxy (правильный способ для 2.516.3)
// System.setProperty('jenkins.model.JenkinsLocationConfiguration.proxyCheck', 'false')


// 3. Назначаем метку встроенной ноде (контроллеру)
def builtInNode = instance
builtInNode.setLabelString("master jmeter dwh")  // можно несколько: "jmeter linux docker"
println "Метка ноды установлена: ${builtInNode.getLabelString()}"

instance.save()

// NOTE Одобрение метода getEnvironment
// import org.jenkinsci.plugins.scriptsecurity.sandbox.whitelists.StaticWhitelist
// import org.jenkinsci.plugins.scriptsecurity.sandbox.groovy.GroovySandbox

// // Получаем доступ к хранилищу одобренных скриптов
// def scriptApproval = org.jenkinsci.plugins.scriptsecurity.sandbox.whitelists.ScriptApproval.get()

// // Сигнатура метода, который вызвал ошибку в Тесте
// def signature = "method org.jenkinsci.plugins.workflow.support.actions.EnvironmentAction getEnvironment"

// // Одобряем метод, если он еще не в списке
// scriptApproval.approveSignature(signature)
// scriptApproval.save()

// println "--- Sandbox Approval: Метод getEnvironment одобрен автоматически ---"

// Одобрение метода getEnvironment
import org.jenkinsci.plugins.scriptsecurity.sandbox.whitelists.ScriptApproval

def scriptApproval = ScriptApproval.get()
scriptApproval.approveSignature("method org.jenkinsci.plugins.workflow.support.actions.EnvironmentAction getEnvironment")
scriptApproval.save()
println "--- Sandbox: Метод getEnvironment одобрен ---"
