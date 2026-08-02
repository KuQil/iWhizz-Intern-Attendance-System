# Stage 1: Build using Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Ant
RUN apt-get update && apt-get install -y ant

# Copy all project files
COPY . .

# Bypass NetBeans IDE-specific CopyLibs task by compiling classes directly and calling default target
RUN ant -Dno.deps=true -Dlibs.CopyLibs.classpath= compile

# Package compiled files into a WAR manually if NetBeans' dist target fails on CopyLibs
RUN ant -Dno.deps=true -Dlibs.CopyLibs.classpath= -Ddo.archive=true dist || \
    (mkdir -p dist && jar cvf dist/app.war -C web .)

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean default Tomcat apps
RUN rm -rf webapps/*

# Copy compiled WAR to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
