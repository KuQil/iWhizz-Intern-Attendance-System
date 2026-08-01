# Stage 1: Build the WAR file using a real JDK image (Java 17)
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Apache Ant
RUN apt-get update && apt-get install -y ant

# Copy your source code
COPY . .

# Run your Ant task to create the WAR file (change 'war' if your build.xml target is named 'dist' or 'build')
RUN ant war

# Stage 2: Deploy to Tomcat 9 (matches your local environment)
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean default apps
RUN rm -rf webapps/*

# Copy the built WAR file to Tomcat as ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
