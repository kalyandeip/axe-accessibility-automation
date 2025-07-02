# Stage 1: Build the application
FROM maven:3.8.1-openjdk-11-slim AS build

WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw mvnw.cmd pom.xml ./
COPY .mvn .mvn

# Ensure the Maven wrapper is executable
RUN chmod +x mvnw

# Download dependencies and build the application
RUN ./mvnw clean install -DskipTests

# Stage 2: Run the application
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
