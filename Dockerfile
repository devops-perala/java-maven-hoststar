FROM tomcat:9.0-jdk17-temurin

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Create a non-root Tomcat user
RUN groupadd -r tomcatuser && \
    useradd -r -g tomcatuser tomcatuser

# Give the Tomcat user ownership of Tomcat
RUN chown -R tomcatuser:tomcatuser /usr/local/tomcat

# Copy application WAR
COPY --chown=tomcatuser:tomcatuser target/myapp.war \
    /usr/local/tomcat/webapps/hotstar.war

# Run Tomcat as non-root user
USER tomcatuser

EXPOSE 8080

CMD ["catalina.sh", "run"]
