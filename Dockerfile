# Use Maven to build the application
FROM maven:3.8.1-openjdk-11-slim AS builder
WORKDIR /app
COPY .mvn/ .mvn/
COPY mvnw mvnw.cmd pom.xml ./
RUN chmod +x mvnw && ./mvnw clean install

# Use OpenJDK to run the application
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
