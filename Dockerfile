# Stage 1: Build the app with Java & Ant
FROM freeleaves/ant:latest AS builder
WORKDIR /app

# Copy source code and build using Ant
COPY . .
RUN ant build   # Adjust target name if needed

# Stage 2: Run Tomcat 9 with JDK 21
FROM tomcat:9.0-jdk21-openjdk-slim
WORKDIR /usr/local/tomcat

# Clean default apps
RUN rm -rf webapps/*

# Copy your built .war file to webapps/ROOT.war
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]