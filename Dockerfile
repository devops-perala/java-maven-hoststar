FROM tomcat:9.0-jdk17-temurin

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Create non-root user and group
RUN groupadd -r tomcatuser && \
    useradd -r -g tomcatuser tomcatuser && \
    chown -R tomcatuser:tomcatuser /usr/local/tomcat

# Copy application
COPY --chown=tomcatuser:tomcatuser target/myapp.war \
    /usr/local/tomcat/webapps/hotstar.war
