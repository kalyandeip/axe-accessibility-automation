# Use Maven to build the project
FROM maven:3.8.1-openjdk-11-slim AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw mvnw.cmd pom.xml ./

# Convert line endings and ensure mvnw is executable
RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix mvnw && \
    chmod +x mvnw && \
    ./mvnw clean install

# Create the final image
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the built JAR file
COPY --from=builder /app/target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
