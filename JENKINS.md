# Jenkins + SonarQube CI Setup

## Prerequisites

- Jenkins with plugins: **SonarQube Scanner**, **Maven Integration**, **Git**
- SonarQube at http://localhost:9000
- Two SonarQube projects: `project-tracker-backend`, `project-tracker-frontend` (each with a token)
- Jenkins credentials: `sonar-backend-token`, `sonar-frontend-token` (Secret text)

## Project Structure

```
project-root/
├── backend/     (Spring Boot)
├── frontend/    (Flutter, has sonar-project.properties)
└── Jenkinsfile
```

## Jenkins Job

- **Type:** Pipeline
- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Script Path:** Jenkinsfile

## Windows Jenkins Agent

If Jenkins runs on **Windows**, change `sh` to `bat` in the Jenkinsfile:

```groovy
bat '''
  mvn clean verify sonar:sonar -Dsonar.projectKey=project-tracker-backend -Dsonar.login=%SONAR_TOKEN%
'''
```

For Flutter, ensure `flutter` and `sonar-scanner` are on the Windows PATH.
