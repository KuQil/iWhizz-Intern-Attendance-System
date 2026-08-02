# Stage 1: Build using Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Copy Tomcat libraries from official Tomcat image to provide servlet-api.jar
COPY --from=tomcat:9-jdk17-corretto /usr/local/tomcat/lib /opt/tomcat/lib

# Copy project source code
COPY . .

# Compile Java sources including Tomcat libraries and local WEB-INF/lib JARs in classpath
RUN mkdir -p web/WEB-INF/classes dist && \
    CP=$(echo /opt/tomcat/lib/*.jar web/WEB-INF/lib/*.jar | tr ' ' ':') && \
    javac -cp "$CP" -d web/WEB-INF/classes $(find src -name "*.java") && \
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
