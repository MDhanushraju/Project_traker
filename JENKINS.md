# Jenkins + SonarQube CI Setup

## Prerequisites

- Jenkins with plugins: **SonarQube Scanner**, **Maven Integration**, **Git**
- SonarQube at http://localhost:9000
- Two SonarQube projects: `project-tracker-backend`, `project-tracker-frontend` (each with a token)
- Jenkins credentials: `sonar-backend-token`, `sonar-frontend-token` (Secret text)

## Three-Repo Setup

| Repo | Jenkinsfile Path | Jenkins Job |
|------|------------------|-------------|
| **All** (monorepo) | `Jenkinsfile` (root) | Both backend + frontend |
| **Backend only** | `backend/Jenkinsfile` | Backend SonarQube |
| **Frontend only** | `frontend/Jenkinsfile` | Frontend SonarQube |

## Jenkins Jobs

Create 3 pipeline jobs (or 1 if you use only the monorepo):

- **project-tracker-all** → Repo with backend + frontend, Script Path: `Jenkinsfile`
- **project-tracker-backend** → Backend-only repo, Script Path: `Jenkinsfile` (root of that repo)
- **project-tracker-frontend** → Frontend-only repo, Script Path: `Jenkinsfile` (root of that repo)

## Windows Jenkins Agent

If Jenkins runs on **Windows**, change `sh` to `bat` in the Jenkinsfile:

```groovy
bat '''
  mvn clean verify sonar:sonar -Dsonar.projectKey=project-tracker-backend -Dsonar.login=%SONAR_TOKEN%
'''
```

For Flutter, ensure `flutter` and `sonar-scanner` are on the Windows PATH.
