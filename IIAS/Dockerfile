# Stage 1: Build using standard Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Ant
RUN apt-get update && apt-get install -y ant

# Copy project source code
COPY . .

# Build the WAR file directly using standard JDK/Ant commands (bypasses NetBeans completely)
RUN mkdir -p web/WEB-INF/classes && \
    javac -d web/WEB-INF/classes $(find src -name "*.java") && \
    mkdir -p dist && \
    jar cvf dist/app.war -C web .

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean default Tomcat apps
RUN rm -rf webapps/*

# Copy compiled WAR to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
