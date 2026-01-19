# Lightweight Java 17 runtime image
FROM eclipse-temurin:17-jre-alpine

# Set working directory inside container
WORKDIR /app

# Copy only the built JAR (artifact)
COPY target/*.jar app.jar

# Expose application port (Spring Boot default)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
