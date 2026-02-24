# JUnit HTML Report — Backend

## Show JUnit results in HTML

**1. Generate and open the report:**
```powershell
cd d:\Project_traker\backend
.\generate-test-report.ps1
```
The script runs tests and opens **surefire-report.html** in your default browser.

**2. Or generate only (open HTML yourself):**
```powershell
cd d:\Project_traker\backend
.\gradlew.bat clean test
```
Then open in browser: **`d:\Project_traker\backend\build\reports\tests\test\index.html`**

## What you see in the HTML

- Summary: total tests, failures, errors, skipped
- Table of test classes with pass/fail and duration
- Click a class for details (which test method failed and why)
