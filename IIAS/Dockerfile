# Stage 1: Build using Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Ant and curl
RUN apt-get update && apt-get install -y ant curl

# Download the missing NetBeans CopyLibs JAR file
RUN mkdir -p /opt/netbeans/extra && \
    curl -sSL -o /opt/netbeans/extra/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    https://repo1.maven.org/maven2/org/netbeans/external/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE120/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE120.jar

# Copy all project files
COPY . .

# Pass BOTH CopyLibs classpath and prop-version flags to Ant
RUN ant \
    -Dlibs.CopyLibs.classpath=/opt/netbeans/extra/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    -Dlibs.CopyLibs.prop-version=3.0 \
    dist

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean out default Tomcat sample apps
RUN rm -rf webapps/*

# Copy generated WAR file to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
