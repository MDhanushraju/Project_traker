# Get users from database via backend API (login first to get token, then GET /api/users).
# Usage: .\scripts\get-users-from-db.ps1
# Or:    .\scripts\get-users-from-db.ps1 -BaseUrl "http://localhost:8080" -Email "admin@taker.com" -Password "Dhanush@03"

param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$Email = "admin@taker.com",
    [string]$Password = "Dhanush@03"
)

$ErrorActionPreference = "Stop"
$headers = @{ "Content-Type" = "application/json"; "Accept" = "application/json" }

# 1. Login to get token
Write-Host "Logging in as $Email ..." -ForegroundColor Cyan
$loginBody = (@{ email = $Email; password = $Password } | ConvertTo-Json -Compress)
try {
    $loginResp = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginBody
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $responseBody = ""
    try {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object System.IO.StreamReader($stream)
            $reader.BaseStream.Position = 0
            $responseBody = $reader.ReadToEnd()
        }
    } catch {}
    Write-Host "Login failed (HTTP $statusCode): $($_.Exception.Message)" -ForegroundColor Red
    if ($responseBody) { Write-Host "Response: $responseBody" -ForegroundColor Yellow }
    Write-Host "  - Restart backend (.\run-backend.ps1) so DataLoader creates/updates admin@taker.com / Dhanush@03" -ForegroundColor Yellow
    Write-Host "  - If still failing, check backend console for the printed exception (stack trace)" -ForegroundColor Yellow
    exit 1
}

$token = $loginResp.data.token
if (-not $token) {
    Write-Host "No token in response." -ForegroundColor Red
    exit 1
}
Write-Host "Login OK." -ForegroundColor Green

# 2. Get users (from database)
$headers["Authorization"] = "Bearer $token"
try {
    $usersResp = Invoke-RestMethod -Uri "$BaseUrl/api/users" -Method GET -Headers $headers
} catch {
    Write-Host "GET /api/users failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$users = $usersResp.data
if (-not $users) { $users = @() }

Write-Host "`nUsers from database ($($users.Count) total):" -ForegroundColor Cyan
Write-Host "----------------------------------------"
foreach ($u in $users) {
    $id = $u.id; $name = $u.fullName; $email = $u.email; $role = $u.role; $pos = $u.position
    Write-Host "  id=$id  $name  $email  role=$role  position=$pos"
}
Write-Host "----------------------------------------"
Write-Host "Done." -ForegroundColor Green
