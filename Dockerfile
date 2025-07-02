# Stage 1: Build with Maven
FROM maven:3.8.1-openjdk-11-slim AS build
WORKDIR /app

# Copy pom & source; adjust paths as needed
COPY pom.xml .
COPY src/ src/

# Download dependencies (leveraging Docker cache)
RUN mvn dependency:go-offline -B

# Build the jar (skip tests for faster builds)
RUN mvn clean package -DskipTests -B

# Stage 2: Package runtime image
FROM openjdk:11-jre-slim
WORKDIR /app

# Add non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy the built jar
COPY --from=build /app/target/*.jar app.jar

# Set ownership
RUN chown appuser:appgroup /app/app.jar

# Use non-root user
USER appuser

# Expose your desired port
EXPOSE 8080

# JVM options (adjust as needed)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run your app
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
