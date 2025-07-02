# syntax=docker/dockerfile:1

FROM maven:3.8.1-openjdk-11-slim AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw mvnw.cmd pom.xml ./

# Install dos2unix and fix line endings
RUN apt-get update && apt-get install -y dos2unix
RUN dos2unix mvnw

# Make mvnw executable
RUN chmod +x mvnw

# Build the project
RUN ./mvnw clean install

FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
