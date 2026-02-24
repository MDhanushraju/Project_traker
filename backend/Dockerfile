# ---------- BUILD STAGE ----------
FROM gradle:8.7-jdk21 AS build

WORKDIR /app

COPY build.gradle settings.gradle gradlew gradlew.bat ./
COPY gradle ./gradle
RUN chmod +x gradlew

COPY src ./src

RUN ./gradlew clean bootJar -x test

# ---------- RUN STAGE ----------
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

# PORT for Render (Render sets PORT env var)
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS:--Xmx256m} -Dserver.port=${PORT:-8080} -jar app.jar"]
