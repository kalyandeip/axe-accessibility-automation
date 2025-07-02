# ─── Stage 1: Build the JAR ───
FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app

# Copy config and source
COPY pom.xml .
COPY src/ ./src/

# Download dependencies (including axe‑selenium)
RUN mvn -B dependency:go-offline

# Package the app
RUN mvn -B clean package -DskipTests

# ─── Stage 2: Runtime ───
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Install Chrome and ChromeDriver
RUN apt-get update && apt-get install -y wget unzip gnupg \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" \
           >> /etc/apt/sources.list.d/google-chrome.list' \
  && apt-get update && apt-get install -y google-chrome-stable \
  && LATEST=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
  && wget -O /tmp/chromedriver.zip \
       "https://chromedriver.storage.googleapis.com/$LATEST/chromedriver_linux64.zip" \
  && unzip /tmp/chromedriver.zip -d /usr/local/bin \
  && rm /tmp/chromedriver.zip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/axe-accessibility-automation-1.0-SNAPSHOT.jar app.jar

# Set Selenium to use headless Chrome
ENV DISPLAY=:99
ENTRYPOINT ["java", "-jar", "app.jar"]
