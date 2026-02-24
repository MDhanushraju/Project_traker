# Generate HTML unit test report (backend) — Gradle
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$gradlew = ".\gradlew.bat"
if (-not (Test-Path $gradlew)) { $gradlew = "gradle" }

& $gradlew clean test

if ($LASTEXITCODE -eq 0) {
    $report = "build\reports\tests\test\index.html"
    if (Test-Path $report) {
        $fullPath = (Resolve-Path $report).Path
        Write-Host "JUnit HTML report: $fullPath" -ForegroundColor Green
        Start-Process $fullPath
    } else {
        Write-Host "Report not found at $report" -ForegroundColor Yellow
    }
} else {
    Write-Host "Build/test failed. See output above." -ForegroundColor Red
    exit 1
}
