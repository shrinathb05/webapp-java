FROM tomcat:10.1-jdk17-temurin-jammy

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/*.war /usr/local/tomcat/webapps/

EXPOSE 8081

CMD ["catalina.sh", "run"]