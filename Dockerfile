# Stage 1: Build the app with Java & Ant
FROM eclipse-temurin:30-jdk AS builder
WORKDIR /app

# Install Apache Ant
RUN apt-get update && apt-get install -y ant

# Copy project files
COPY . .

# Run your build (change 'war' to your actual target name)
RUN ant

# Stage 2: Run the app with Tomcat 10
FROM tomcat:9-jdk30-corretto
WORKDIR /usr/local/tomcat

# Clean default Tomcat apps
RUN rm -rf webapps/*

# Copy the built .war file (adjust /app/dist/*.war if your output folder is different, e.g., /app/build/*.war)
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
