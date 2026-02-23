# Generate HTML coverage report (frontend)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# Step 1: Run tests with coverage
flutter test --coverage

if (-not (Test-Path "coverage\lcov.info")) {
    Write-Host "No coverage data. Add tests in test/ folder." -ForegroundColor Yellow
    exit 0
}

# Step 2: Try flutter_coverage_report (no lcov needed)
if (Get-Command "dart" -ErrorAction SilentlyContinue) {
    dart pub global activate flutter_coverage_report 2>$null
    dart run flutter_coverage_report coverage/lcov.info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Report generated. Open the HTML file shown above." -ForegroundColor Green
        exit 0
    }
}

# Step 3: Fallback - use genhtml if lcov installed
if (Get-Command "genhtml" -ErrorAction SilentlyContinue) {
    New-Item -ItemType Directory -Path "coverage\html" -Force | Out-Null
    genhtml coverage/lcov.info -o coverage/html
    if ($LASTEXITCODE -eq 0 -and (Test-Path "coverage\html\index.html")) {
        Write-Host "Report: coverage\html\index.html" -ForegroundColor Green
        Start-Process "coverage\html\index.html"
    }
} else {
    Write-Host "Coverage saved to coverage\lcov.info" -ForegroundColor Cyan
    Write-Host "Install lcov (choco install lcov) or flutter_coverage_report for HTML." -ForegroundColor Yellow
}
