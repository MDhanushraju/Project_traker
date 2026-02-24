# Project Tracker — Backend (Spring Boot)

REST API for the Project Tracker app. Requires **PostgreSQL** and **JDK 21**. Build: **Gradle**.

## How to run

| Option | Command |
|--------|---------|
| PowerShell script | `.\run-backend.ps1` |
| Gradle | `.\gradlew.bat bootRun` or `gradle bootRun` |
| With Java path | `$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"; .\gradlew.bat bootRun` |

## Endpoints

- **API:** http://localhost:8080
- **Swagger:** http://localhost:8080/swagger-ui.html

## HTML unit test report

```powershell
.\generate-test-report.ps1
```

Report: `build\reports\tests\test\index.html` — see `docs/HTML_TEST_REPORT.md`.

## Docker (containerized)

**Backend only (expects PostgreSQL on host or elsewhere):**
```powershell
cd D:\Project_traker\backend
docker build -t project-tracker-backend .
docker run -p 8080:8080 -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/project_tracker -e SPRING_DATASOURCE_USERNAME=postgres -e SPRING_DATASOURCE_PASSWORD=Dhanush@03 project-tracker-backend
```

**Backend + PostgreSQL (recommended):**
```powershell
cd D:\Project_traker\backend
docker compose up -d
```
Then open http://localhost:8080 and http://localhost:8080/swagger-ui.html. Stop with `docker compose down`.

## Deploy (Railway / Railpack)

1. In Railway: **Settings → General → Root Directory** set to **`backend`**.
2. Ensure **`gradle/wrapper/gradle-wrapper.jar`** is committed (required for `./gradlew` in the image). If it’s missing, add it and push.
3. Redeploy. Nixpacks will detect Gradle and run `./gradlew clean build` then `java -jar build/libs/*.jar` with `PORT` set by Railway.

## Structure

```
backend/
├── src/                 # Java source
├── build.gradle         # Gradle build
├── settings.gradle
├── gradle/wrapper/      # Gradle wrapper (include gradle-wrapper.jar for CI/deploy)
├── Dockerfile            # Container image (multi-stage Gradle → JRE)
├── docker-compose.yml    # Backend + PostgreSQL
├── run-backend.ps1      # Start script
├── generate-test-report.ps1   # HTML test report
├── docs/                # SONARQUBE.md, SWAGGER.md, HTML_TEST_REPORT.md, JUNIT_SAST_API.md
├── scripts/
└── (no Maven: pom.xml, .mvn, mvnw removed)
```

If the **`.mvn`** folder is still present (e.g. locked during conversion), close any process using it (IDE, running backend) and delete it manually: `Remove-Item -Recurse -Force .mvn`.
