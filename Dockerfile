# build-env container
FROM maven:3-jdk-8-slim AS build-env

# Additional tools required for the build
RUN apt-get update -q -y && \
    apt-get install -q -y bzip2 git

# Pull and build
RUN cd /usr/src && \
    git clone https://github.com/pwm-project/pwm.git && \
    cd /usr/src/pwm && \
    mvn --batch-mode clean package

# application container
FROM tomcat:9-jdk11-openjdk-slim

# Config
VOLUME /usr/local/tomcat/webapps/login/config
# HTTPS port
EXPOSE 8443
# HTTP port
EXPOSE 8080

COPY --from=build-env /usr/src/pwm/webapp/target/pwm-*.war /usr/local/tomcat/webapps/login.war
RUN cd /usr/local/tomcat/webapps/login && \
    jar -x --file=../login.war && \
    chmod a+x /usr/local/tomcat/webapps/login/WEB-INF/command.sh
