# Unit Test Results in HTML – Step by Step

## Quick Scripts

- **Backend:** `cd backend` → `.\generate-test-report.ps1`
- **Frontend:** `cd frontend` → `.\generate-test-report.ps1`

## Frontend (Flutter)

### Option A: Coverage HTML Report (recommended)

**Step 1.** Open terminal and go to frontend:
```powershell
cd d:\Project_traker\frontend
```

**Step 2.** Run tests with coverage:
```powershell
flutter test --coverage
```
This creates `coverage/lcov.info`.

**Step 3.** Install lcov (one-time, for genhtml):

- **Chocolatey:** `choco install lcov`
- **Scoop:** `scoop install lcov`
- **Manual:** Download from https://github.com/linux-test-project/lcov/releases

**Step 4.** Generate HTML report:
```powershell
genhtml coverage/lcov.info -o coverage/html
```

**Step 5.** Open the report:
```powershell
start coverage/html/index.html
```

---

### Option B: Use flutter_coverage_report (no lcov needed)

**Step 1.** Install the tool (one-time):
```powershell
dart pub global activate flutter_coverage_report
```

**Step 2.** Run tests and generate report:
```powershell
cd d:\Project_traker\frontend
flutter test --coverage
dart run flutter_coverage_report coverage/lcov.info
```

**Step 3.** Open the generated HTML file (path shown in the command output).

---

## Backend (Java / Maven)

### Generate HTML test report

**Step 1.** Add the Surefire Report plugin to `backend/pom.xml` (in the `<plugins>` section):
```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-surefire-report-plugin</artifactId>
  <version>3.2.5</version>
  <executions>
    <execution>
      <phase>test</phase>
      <goals>
        <goal>report-only</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

**Step 2.** Run tests and generate report:
```powershell
cd d:\Project_traker\backend
.\mvnw.cmd clean test surefire-report:report-only
```

**Step 3.** Open the HTML report:
```powershell
start target\site\surefire-report.html
```

---

## Quick summary

| Project  | Command                                                  | Report location                |
|----------|----------------------------------------------------------|--------------------------------|
| Frontend | `flutter test --coverage` + `genhtml` or `flutter_coverage_report` | `frontend/coverage/html/index.html` |
| Backend  | `mvnw.cmd test surefire-report:report-only`              | `backend/target/site/surefire-report.html` |
