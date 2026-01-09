FROM tomcat:9.0.112-jre17

RUN rm -rf /usr/local/tomcat/webapps/*

COPY webapps/ROOT /usr/local/tomcat/webapps/ROOT

COPY lib/mariadb-java-client-3.4.1.jar /usr/local/tomcat/lib/

COPY setenv.sh /usr/local/tomcat/bin/setenv.sh
RUN chmod +x /usr/local/tomcat/bin/setenv.sh

EXPOSE 8080
