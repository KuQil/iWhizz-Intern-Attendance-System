# Stage 1: Build using Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Ant and curl
RUN apt-get update && apt-get install -y ant curl

# Download updated NetBeans CopyLibs JARs directly into Ant's global library folder
RUN curl -sSL -o /usr/share/ant/lib/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    https://repo1.maven.org/maven2/org/netbeans/external/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE180/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE180.jar

# Copy all project files
COPY . .

# Build the WAR file (Ant now has CopyLibs loaded globally)
RUN ant dist

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean out default Tomcat sample apps
RUN rm -rf webapps/*

# Copy generated WAR file to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
