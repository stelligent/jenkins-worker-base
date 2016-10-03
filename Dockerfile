FROM registry.access.redhat.com/rhel7.1
MAINTAINER Casey Lee <casey.lee@stelligent.com>

# Setup yum repo
COPY files/CentOS.repo /etc/yum.repos.d/CentOS.repo
RUN subscription-manager config --rhsm.manage_repos=0
RUN rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-7

# Setup base tools
RUN yum install -y git

ENV JAVA_VERSION 8u31
ENV JAVA_BUILD_VERSION b13
ENV JENKINS_VERSION 2.62

# Downloading Java
RUN curl -s -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm > /tmp/jdk-8-linux-x64.rpm

# Install Java
RUN yum -y install /tmp/jdk-8-linux-x64.rpm

# Setup Java paths
RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest

# Setup Jenkins User
ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins

# Download Jenkins slave
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_VERSION}/remoting-${JENKINS_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar


# Setup Jenkins User homedir
USER jenkins
RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

COPY files/jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]