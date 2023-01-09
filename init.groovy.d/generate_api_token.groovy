import hudson.model.*
import jenkins.model.*
import jenkins.security.*
import jenkins.security.apitoken.*

// script parameters
def userName = 'admin'
def tokenName = 'initial-token'

def user = User.get(userName, false)
def apiTokenProperty = user.getProperty(ApiTokenProperty.class)
def result = apiTokenProperty.tokenStore.generateNewToken(tokenName)
user.save()

// Write to JJB config
def file = new File('/etc/jenkins_jobs/jenkins_jobs.ini')
def newConfig =  file.text.replace('password=', 'password=' + result.plainValue)
file.text = newConfig

return result.plainValue