# Stage 1: Build using Official NetBeans + JDK 17
FROM apache/netbeans:17-jdk17 AS builder
WORKDIR /app

# Switch to root user to copy project files
USER root

# Copy project source code
COPY . .

# Run ant dist using NetBeans' installed CopyLibs task library
RUN ant \
    -Dlibs.CopyLibs.classpath=/usr/lib/netbeans/java/ant/extra/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    dist

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean default Tomcat apps
RUN rm -rf webapps/*

# Copy compiled WAR file to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
