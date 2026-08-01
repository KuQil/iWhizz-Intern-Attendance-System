# Stage 1: Build the app with Java & Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Apache Ant
RUN apt-get update && apt-get install -y ant

# Copy project files and compile using Ant
COPY . .
RUN ant build   # Replace 'build' with your specific target if different (e.g., ant war)

# Stage 2: Run the app with Tomcat 10
FROM tomcat:10-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean default Tomcat apps
RUN rm -rf webapps/*

# Copy the built .war file to Tomcat (renamed to ROOT.war for root path routing)
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
