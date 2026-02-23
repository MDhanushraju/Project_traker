# Project Tracker

Full-stack project management app with Flutter UI and Spring Boot API.

## Overview

- **Backend:** REST API (Spring Boot, PostgreSQL, JWT auth)
- **Frontend:** Flutter app (Web, Windows, Android, iOS)
- **CI/CD:** Jenkins + SonarQube (see JENKINS.md)

## Tech Stack

| Layer    | Technology                    |
|----------|-------------------------------|
| Backend  | **Maven**, Spring Boot 3, Java 21, JPA, PostgreSQL |
| Frontend | Flutter, Dart                 |
| Auth     | JWT                           |
| API docs | Swagger / OpenAPI             |

## Structure

```
Project_traker/
├── backend/       # Spring Boot API
├── frontend/      # Flutter app
├── Jenkinsfile    # CI pipeline (backend + frontend)
└── JENKINS.md     # Jenkins setup guide
```

## How to Run

**Backend** (Maven; requires PostgreSQL):
```powershell
cd backend
.\run-backend.ps1
# or: .\mvnw.cmd spring-boot:run   (Maven wrapper)   (Maven wrapper)
```

**Frontend:**
```powershell
cd frontend
.\run-frontend.ps1
# or: flutter run -d chrome
```

- **API:** http://localhost:8080
- **Swagger:** http://localhost:8080/swagger-ui.html
