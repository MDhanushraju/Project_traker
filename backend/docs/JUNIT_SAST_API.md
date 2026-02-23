# JUnit Testing · SAST · API — HTML Reports & Docs

| Report | Type | How to open / generate |
|--------|------|------------------------|
| **JUnit test (HTML)** | Unit test results | Generate, then open file below |
| **SAST (SonarQube)** | Code quality & security | Web UI (see below) |
| **API (Swagger)** | REST API docs | Web UI when backend is running |

---

## 1. JUnit testing → HTML report

**Generate:**
```powershell
cd d:\Project_traker\backend
.\generate-test-report.ps1
```

**Open HTML:**  
`backend\target\site\surefire-report.html`

Shows: test count, pass/fail, duration, and per-class results.

---

## 2. SAST → SonarQube (HTML in browser)

**Run analysis (after SonarQube is set up):**
```powershell
cd d:\Project_traker\backend
.\.mvn\maven\bin\mvn.cmd clean verify sonar:sonar -Dsonar.projectKey=project-tracker-backend -Dsonar.host.url=http://localhost:9000 -Dsonar.token=YOUR_TOKEN
```

**Open HTML (SonarQube is the report – no separate .html file):**  
1. Open **http://localhost:9000** in your browser.  
2. Log in → **Projects** → select `project-tracker-backend` (or `project-tracker-frontend`).  
3. The project page is the “test”/quality report: issues, security hotspots, coverage, quality gate (all HTML in browser).

---

## 3. API → Swagger (HTML in browser)

**Start backend first**, then open:

**http://localhost:8080/swagger-ui.html**

Shows: all REST endpoints, try-it-out, request/response schemas (HTML in browser).

---

## Quick reference

| What | URL or path |
|------|-------------|
| JUnit HTML | `backend\target\site\surefire-report.html` (after `.\generate-test-report.ps1`) |
| SAST HTML | http://localhost:9000 |
| API HTML | http://localhost:8080/swagger-ui.html |


to get test report
cd d:\Project_traker\backend
.\generate-test-report.ps1
