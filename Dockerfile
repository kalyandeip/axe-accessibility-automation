# syntax=docker/dockerfile:1

################################################################################
# Stage 1: Build using Maven (includes wrapper generation)
FROM eclipse-temurin:21 AS builder
WORKDIR /app

# Generate Maven wrapper inside container (no need to include in repo)
RUN mvn -N io.takari:maven:wrapper

# Copy wrapper and pom only (to leverage dependency caching)
COPY pom.xml .mvn/ mvnw mvnw.cmd ./

# Pre-download dependencies for caching
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw dependency:go-offline -B

# Copy source and build
COPY src/ ./src/
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw clean package -DskipTests -B

################################################################################
# Stage 2: Create lean runtime image
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

RUN addgroup -S appgroup && adduser -S -G appgroup appuser
COPY --from=builder /app/target/*.jar app.jar
RUN chown appuser:appgroup /app/app.jar
USER appuser

EXPOSE 8080
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
