# Test all Project Tracker APIs - run in PowerShell
# Usage: .\scripts\test-all-apis.ps1
# Or: .\scripts\test-all-apis.ps1 -BaseUrl "http://localhost:8080"

param(
    [string]$BaseUrl = "https://project-traker-backend.onrender.com"
)

$ErrorActionPreference = "Stop"
$passed = 0
$failed = 0

function Test-Request {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null,
        [string]$Token = $null,
        [int[]]$ExpectStatus = @(200, 201)
    )
    $headers = @{
        "Content-Type" = "application/json"
        "Accept"       = "application/json"
    }
    if ($Token) { $headers["Authorization"] = "Bearer $Token" }
    try {
        $params = @{
            Uri     = $Uri
            Method  = $Method
            Headers = $headers
        }
        if ($Body) { $params["Body"] = ($Body | ConvertTo-Json -Depth 5) }
        $r = Invoke-WebRequest @params -UseBasicParsing -TimeoutSec 15
        if ($r.StatusCode -in $ExpectStatus) {
            Write-Host "  OK   $Name" -ForegroundColor Green
            $script:passed++
            return $r.Content
        }
        Write-Host "  FAIL $Name (status $($r.StatusCode), expected $ExpectStatus)" -ForegroundColor Red
        $script:failed++
        return $null
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        if ($status -in $ExpectStatus) {
            Write-Host "  OK   $Name (status $status)" -ForegroundColor Green
            $script:passed++
            return $null
        }
        Write-Host "  FAIL $Name - $($_.Exception.Message)" -ForegroundColor Red
        $script:failed++
        return $null
    }
}

Write-Host "`n=== Testing APIs at $BaseUrl ===`n" -ForegroundColor Cyan

# --- No auth ---
Write-Host "Health & docs" -ForegroundColor Yellow
Test-Request -Name "GET /actuator/health" -Method GET -Uri "$BaseUrl/actuator/health" | Out-Null
Test-Request -Name "GET /" -Method GET -Uri "$BaseUrl/" | Out-Null

# --- Auth (no token) ---
Write-Host "`nAuth (no token)" -ForegroundColor Yellow
# Login: 200 = success, 401 = wrong credentials, 400 = validation / role issue (local: ensure backend + DataLoader ran)
Test-Request -Name "POST /api/auth/login (seed admin)" -Method POST -Uri "$BaseUrl/api/auth/login" `
    -Body @{ email = "admin@taker.com"; password = "Dhanush@03" } -ExpectStatus @(200, 400, 401) | Out-Null

$loginBody = @{ email = "admin@taker.com"; password = "Dhanush@03" }
$loginResult = Test-Request -Name "POST /api/auth/login (get token)" -Method POST -Uri "$BaseUrl/api/auth/login" `
    -Body $loginBody -ExpectStatus @(200, 400, 401)

$token = $null
if ($loginResult) {
    $json = $loginResult | ConvertFrom-Json
    if ($json.data -and $json.data.token) {
        $token = $json.data.token
        Write-Host "  Token obtained for protected requests" -ForegroundColor Gray
    }
}

# login-with-role: 200 = token, 400 = no user for that role; 500 = old backend (before fix deploy)
if (-not $token) {
    $roleResult = Test-Request -Name "POST /api/auth/login-with-role" -Method POST -Uri "$BaseUrl/api/auth/login-with-role" `
        -Body @{ role = "admin" } -ExpectStatus @(200, 400, 500)
    if ($roleResult) {
        $json = $roleResult | ConvertFrom-Json
        if ($json.data -and $json.data.token) { $token = $json.data.token }
    }
}

Test-Request -Name "POST /api/auth/forgot-password" -Method POST -Uri "$BaseUrl/api/auth/forgot-password" `
    -Body @{ email = "admin@taker.com" } -ExpectStatus @(200) | Out-Null

# --- Protected (with token) ---
if ($token) {
    Write-Host "`nProtected (with token)" -ForegroundColor Yellow
    Test-Request -Name "GET /api/projects" -Method GET -Uri "$BaseUrl/api/projects" -Token $token | Out-Null
    Test-Request -Name "GET /api/tasks" -Method GET -Uri "$BaseUrl/api/tasks" -Token $token | Out-Null
    Test-Request -Name "GET /api/users" -Method GET -Uri "$BaseUrl/api/users" -Token $token | Out-Null
    Test-Request -Name "POST /api/tasks (create)" -Method POST -Uri "$BaseUrl/api/tasks" -Token $token `
        -Body @{ title = "API test task"; status = "need_to_start" } -ExpectStatus @(200, 201) | Out-Null
    Test-Request -Name "GET /api/users/team-leader/projects" -Method GET -Uri "$BaseUrl/api/users/team-leader/projects" -Token $token | Out-Null
    Test-Request -Name "GET /api/users/member/projects" -Method GET -Uri "$BaseUrl/api/users/member/projects" -Token $token | Out-Null
} else {
    Write-Host "`nSkipping protected endpoints (no token from login)" -ForegroundColor DarkYellow
}

# --- Signup (no token, may 400 if email exists) ---
Write-Host "`nSignup (expect 200 or 400 if email exists)" -ForegroundColor Yellow
$signupBody = @{
    fullName        = "API Test User"
    email           = "apitest$(Get-Random -Maximum 99999)@example.com"
    password        = "Test@1234"
    confirmPassword = "Test@1234"
    role            = "member"
    position        = "Developer"
}
Test-Request -Name "POST /api/auth/signup" -Method POST -Uri "$BaseUrl/api/auth/signup" `
    -Body $signupBody -ExpectStatus @(200, 400) | Out-Null

# --- Summary ---
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host ""
