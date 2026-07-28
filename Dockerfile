FROM tomcat:9.0-jdk17-temurin

COPY target/myapp.war /usr/local/tomcat/webapps/hotstar.war

EXPOSE 8080
