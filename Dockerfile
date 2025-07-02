# Stage 1: Build the application
FROM maven:3.6.3-jdk-11-slim AS builder

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY .mvn/ .mvn/
COPY mvnw mvnw.cmd pom.xml ./

# Download dependencies and cache them
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw dependency:go-offline -B

# Copy source code after dependencies to leverage build caching
COPY src/ ./src/

# Build the application
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw package -DskipTests -B

# Stage 2: Create runtime image
FROM openjdk:11-jre-slim

# Add a non-root user to run the app
RUN addgroup --system javauser && adduser --system --ingroup javauser javauser

# Set working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Set ownership of the application files to non-root user
RUN chown -R javauser:javauser /app

# Switch to non-root user
USER javauser

# Expose application port
EXPOSE 8080

# Configure JVM options (optimized for containers)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
