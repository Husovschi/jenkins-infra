FROM jenkins/jenkins:lts

ENV CASC_JENKINS_CONFIG=$JENKINS_HOME/casc_configs

# Install container requirements
USER root
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install --no-install-recommends -y \
    git \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install docker (https://docs.docker.com/engine/install/debian/)
## Add Docker’s official GPG key
WORKDIR /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

## Set up the repository
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

## Install Docker Engine
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install --no-install-recommends -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

## Add user jenkins to docker group
RUN usermod -aG docker jenkins

# Skip initial setup
## Indicate that this Jenkins installation is fully configured
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
## Copy init goovy files
COPY init.groovy.d/ /var/jenkins_home/init.groovy.d/

# Install plugins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/plugins.txt

# Set up casc
## Copy casc configs
COPY casc_configs $JENKINS_HOME/casc_configs/

# Install JJB
RUN apt-get update && apt-get install --no-install-recommends -y \
    jenkins-job-builder \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Copy jobs
COPY --chown=jenkins:jenkins jenkins_jobs/ /etc/jenkins_jobs/
COPY --chown=jenkins:jenkins jenkins_jobs/xml/JBB-update-jenkins-jobs.xml /usr/share/jenkins/ref/jobs/JBB-update-jenkins-jobs/config.xml

#RUN jenkins-jobs update /etc/jenkins_jobs/aws_infra/manage_aws_infra.yaml 
USER jenkins