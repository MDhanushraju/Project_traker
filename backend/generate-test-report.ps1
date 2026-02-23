# Generate HTML unit test report (backend)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$mvn = ".\.mvn\maven\bin\mvn.cmd"
if (-not (Test-Path $mvn)) { $mvn = "mvn" }

& $mvn clean test surefire-report:report-only

if ($LASTEXITCODE -eq 0) {
    $report = "target\site\surefire-report.html"
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
