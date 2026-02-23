# Project Tracker — Backend (Spring Boot)

REST API for the Project Tracker app. Requires **PostgreSQL** and **JDK 21**.

## How to run

| Option | Command |
|--------|---------|
| PowerShell script | `.\run-backend.ps1` |
| Maven | `mvn spring-boot:run` |
| Maven wrapper | `./mvnw spring-boot:run` or `mvnw.cmd spring-boot:run` |
| With Java path | `$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"; mvn spring-boot:run` |

## Endpoints

- **API:** http://localhost:8080
- **Swagger:** http://localhost:8080/swagger-ui.html

## HTML unit test report

```powershell
.\generate-test-report.ps1
```

Report: `target\site\surefire-report.html` — see `docs/HTML_TEST_REPORT.md`.

## Deploy (Railway / Railpack)

The backend is **Maven-only** for deploy; `nixpacks.toml` forces Maven so the build does not use Gradle (which can fail with “Unable to access jarfile gradle-wrapper.jar”).

1. In Railway: **Settings → General → Root Directory** set to **`backend`** (so only this app is built).
2. Redeploy. Nixpacks will use `nixpacks.toml`: Maven build and `java -jar target/*.jar` with `PORT` set by Railway.

## Structure

```
backend/
├── src/                 # Java source
├── run-backend.ps1      # Start script
├── generate-test-report.ps1   # HTML test report
├── nixpacks.toml        # Railway/Nixpacks: use Maven (not Gradle)
├── docs/                # SONARQUBE.md, SWAGGER.md, HTML_TEST_REPORT.md, JUNIT_SAST_API.md
├── scripts/
└── pom.xml
```
