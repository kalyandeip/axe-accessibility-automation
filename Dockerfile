# syntax=docker/dockerfile:1

FROM maven:3.8.1-openjdk-11-slim AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw mvnw.cmd pom.xml ./

# Ensure the Maven wrapper is executable and convert line endings
RUN apt-get update && apt-get install -y dos2unix \
    && dos2unix mvnw \
    && chmod +x mvnw

# Download dependencies and cache them
RUN ./mvnw dependency:resolve

# Copy the rest of the application
COPY src ./src

# Build the application
RUN ./mvnw clean install

# Stage 2: Run the application
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
