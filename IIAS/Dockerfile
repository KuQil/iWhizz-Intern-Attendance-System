# Stage 1: Build using Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Ant and curl
RUN apt-get update && apt-get install -y ant curl

# Create directory for NetBeans Ant tasks
RUN mkdir -p /opt/netbeans/extra

# Download both CopyLibs and CopyFiles task JARs from Maven Central
RUN curl -sSL -o /opt/netbeans/extra/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    https://repo1.maven.org/maven2/org/netbeans/external/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE180/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE180.jar && \
    curl -sSL -o /opt/netbeans/extra/org-netbeans-modules-java-j2seproject-copyfilestask.jar \
    https://repo1.maven.org/maven2/org/netbeans/external/org-netbeans-modules-java-j2seproject-copyfilestask/RELEASE180/org-netbeans-modules-java-j2seproject-copyfilestask-RELEASE180.jar

# Copy project source code
COPY . .

# Run ant dist passing BOTH JARs in the classpath (separated by a colon)
RUN ant -Dlibs.CopyLibs.classpath=/opt/netbeans/extra/org-netbeans-modules-java-j2seproject-copylibstask.jar:/opt/netbeans/extra/org-netbeans-modules-java-j2seproject-copyfilestask.jar dist

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean default Tomcat apps
RUN rm -rf webapps/*

# Copy compiled WAR to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
