# Stage 1: Build the application
FROM maven:3.8.1-openjdk-11-slim AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw mvnw.cmd pom.xml ./

# Make mvnw executable and convert line endings
RUN chmod +x mvnw && dos2unix mvnw

# Install dependencies
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src ./src/

# Build the application
RUN ./mvnw package -DskipTests

# Stage 2: Create runtime image
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the built JAR file
COPY --from=builder /app/target/*.jar app.jar

# Run the application
CMD ["java", "-jar", "app.jar"]
