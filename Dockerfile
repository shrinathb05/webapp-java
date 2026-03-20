FROM tomcat:10.1-jdk17-temurin-jammy

# Clear it out to make room for your app
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy and rename
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]