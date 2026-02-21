# SonarQube Setup Guide

## 1. Install Cursor / VS Code Extension

1. Open **Extensions** (Ctrl+Shift+X)
2. Search for **SonarLint** or **SonarQube**
3. Install **SonarLint** (free, provides inline analysis)
4. Optionally install **SonarQube** extension if you want to connect to your server

## 2. Connect SonarLint to Your SonarQube Server

1. Open **Settings** (Ctrl+,)
2. Search for `sonarlint`
3. Under **SonarLint > Connected Mode**, click **Add SonarQube Connection**
4. Set:
   - **Connection ID**: e.g. `taker-sonar`
   - **Server URL**: `http://localhost:9000` (or your SonarQube URL)
   - **Token**: Create one in SonarQube → My Account → Security → Generate Token

## 3. Run SonarQube Analysis (Backend)

The backend is in `backend/`. Run from the **backend** folder:

From the **backend** folder:

```powershell
cd d:\Project_traker\backend
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"

# Set SonarQube URL and token (replace with your values)
$env:SONAR_HOST_URL = "http://localhost:9000"
$env:SONAR_TOKEN = "your-sonarqube-token"

.\.mvn\maven\bin\mvn.cmd clean verify sonar:sonar
```

Or create a token in SonarQube and pass it directly:

```powershell
.\.mvn\maven\bin\mvn.cmd sonar:sonar -Dsonar.token=YOUR_TOKEN -Dsonar.host.url=http://localhost:9000
```

## 4. Create Project in SonarQube (First Time)

1. Open SonarQube: **http://localhost:9000**
2. Log in (default: admin / admin)
3. Go to **Projects** → **Create project manually**
4. **Project key**: `project-tracker-backend`
5. **Display name**: `Project Tracker Backend`

## 5. Configuration (Optional)

Create `sonar-project.properties` in the backend folder to customize:

```properties
sonar.projectKey=project-tracker-backend
sonar.projectName=Project Tracker Backend
sonar.host.url=http://localhost:9000
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.exclusions=**/config/**,**/dto/**
```

Or pass via Maven:

```powershell
mvn sonar:sonar -Dsonar.projectKey=project-tracker-backend -Dsonar.host.url=http://localhost:9000 -Dsonar.token=YOUR_TOKEN
```

## 6. Flutter / Dart Support

For Flutter analysis in SonarQube:

1. Install **SonarDart** plugin in SonarQube (Admin → Marketplace)
2. Use **SonarScanner** (CLI) with a `sonar-project.properties` at project root
3. Or use **SonarLint** extension – it analyzes Dart/Flutter inline without a server

## Quick Commands

| Task | Command |
|------|---------|
| Run analysis (backend) | `cd backend; mvn sonar:sonar -Dsonar.token=TOKEN -Dsonar.host.url=http://localhost:9000` |
| Run with defaults | Ensure `SONAR_HOST_URL` and `SONAR_TOKEN` env vars are set, then `mvn sonar:sonar` |
