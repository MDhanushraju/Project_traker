# How to Run the Project

## 1. Run Backend

**PowerShell (from project root):**
```powershell
cd d:\Project_traker\backend
.\run-backend.ps1
```

**Or use Maven wrapper** (if `mvn` is not on PATH):
```powershell
cd d:\Project_traker\backend
.\mvnw.cmd spring-boot:run
```

- API: http://localhost:8080
- Swagger: http://localhost:8080/swagger-ui.html
- Requires: PostgreSQL running, JDK 21

---

## 2. Run Frontend

**PowerShell (from project root):**
```powershell
cd d:\Project_traker\frontend
.\run-frontend.ps1
```

**Or step by step:**
```powershell
cd d:\Project_traker\frontend
flutter pub get
flutter run -d chrome
```

**Other platforms:**
```powershell
flutter run -d windows
flutter run -d android
flutter run -d ios
```

---

## 3. Jenkins – How to Operate

### Create a Pipeline Job

1. Open Jenkins → **New Item**
2. Name: `project-tracker-all` (or `project-tracker-backend` / `project-tracker-frontend`)
3. Choose **Pipeline** → OK
4. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: your repo URL (or `file:///d:/Project_traker` for local)
   - Script Path: `Jenkinsfile` (or `backend/Jenkinsfile`, `frontend/Jenkinsfile`)
5. **Save**

### Run the Pipeline

1. Open the job
2. Click **Build Now**
3. See progress in **Build History** → click build number → **Console Output**

### Add Credentials (SonarQube tokens)

1. **Manage Jenkins** → **Credentials** → **(global)**
2. **Add Credentials**
3. Kind: **Secret text**
4. Secret: paste your SonarQube token
5. ID: `sonar-backend-token` or `sonar-frontend-token`

---

## 4. SonarQube – How to Operate

### First-Time Setup

1. Open http://localhost:9000
2. Log in (default: admin / admin)
3. **Create project**:
   - **project-tracker-backend** (manual)
   - **project-tracker-frontend** (manual)
4. For each project: **Generate token** → copy and save
5. Add those tokens to Jenkins (see above)

### Run SonarQube Locally (Backend)

```powershell
cd d:\Project_traker\backend
$env:SONAR_HOST_URL = "http://localhost:9000"
$env:SONAR_TOKEN = "your-token-here"
.\mvnw.cmd clean verify sonar:sonar -Dsonar.projectKey=project-tracker-backend
```

### Run SonarQube Locally (Frontend)

```powershell
cd d:\Project_traker\frontend
$env:SONAR_HOST_URL = "http://localhost:9000"
$env:SONAR_TOKEN = "your-token-here"
flutter test
sonar-scanner -Dsonar.projectKey=project-tracker-frontend -Dsonar.login=$env:SONAR_TOKEN -Dsonar.host.url=$env:SONAR_HOST_URL
```

### View Results

1. Open http://localhost:9000
2. **Projects** → select `project-tracker-backend` or `project-tracker-frontend`
3. Review **Issues**, **Security Hotspots**, **Code Smells**, **Coverage**
