# Stage 1: Build using Java 17 and Apache Ant
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Install Ant
RUN apt-get update && apt-get install -y ant

# Copy all repository files (including the crucial nbproject folder)
COPY . .

# NetBeans' build target is 'default' or 'dist'
RUN ant dist

# Stage 2: Deploy to Tomcat 9
FROM tomcat:9-jdk17-corretto
WORKDIR /usr/local/tomcat

# Clean out default Tomcat sample apps
RUN rm -rf webapps/*

# NetBeans puts the generated WAR file in /app/dist/
# We copy and rename it to ROOT.war so Tomcat serves it on the root URL
COPY --from=builder /app/dist/*.war webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
