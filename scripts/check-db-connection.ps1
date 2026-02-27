# Quick check: is the backend running and is the database connected?
# Usage: .\scripts\check-db-connection.ps1
# Or:    .\scripts\check-db-connection.ps1 -BaseUrl "http://localhost:8080"

param([string]$BaseUrl = "http://localhost:8080")

try {
    $r = Invoke-WebRequest -Uri "$BaseUrl/actuator/health" -UseBasicParsing -TimeoutSec 5
    $json = $r.Content | ConvertFrom-Json
    $status = $json.status
    $dbStatus = $json.components.db.status
    Write-Host "Backend: $status" -ForegroundColor $(if ($status -eq "UP") { "Green" } else { "Red" })
    Write-Host "Database: $dbStatus" -ForegroundColor $(if ($dbStatus -eq "UP") { "Green" } else { "Red" })
    if ($status -eq "UP" -and $dbStatus -eq "UP") {
        Write-Host "`nDatabase is connected." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`nDatabase is NOT connected. Start backend (.\run-backend.ps1) and check PostgreSQL is running." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "Cannot reach backend at $BaseUrl" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nStart the backend first: cd backend; .\run-backend.ps1" -ForegroundColor Yellow
    exit 1
}
