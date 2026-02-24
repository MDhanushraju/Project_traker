# Run Spring Boot backend with Gradle
$ErrorActionPreference = "Stop"
$ProjectDir = $PSScriptRoot

# Find Java
$JavaExe = $null
if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME "bin\java.exe"))) {
    $JavaExe = Join-Path $env:JAVA_HOME "bin\java.exe"
}
if (-not $JavaExe) {
    try { $JavaExe = (Get-Command java -ErrorAction Stop).Source } catch {}
}
if (-not $JavaExe) {
    $jdk21 = Join-Path ${env:ProgramFiles} "Java\jdk-21\bin\java.exe"
    if (Test-Path $jdk21) { $JavaExe = $jdk21 }
}
if (-not $JavaExe) {
    $paths = @(
        "${env:ProgramFiles}\Java\jdk-21*\bin\java.exe",
        "${env:ProgramFiles}\Java\jdk-17*\bin\java.exe",
        "${env:ProgramFiles}\Eclipse Adoptium\jdk-21*\bin\java.exe",
        "${env:ProgramFiles}\Microsoft\jdk-21*\bin\java.exe"
    )
    foreach ($p in $paths) {
        $resolved = Get-Item $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved) { $JavaExe = $resolved.FullName; break }
    }
}
if (-not $JavaExe -or -not (Test-Path $JavaExe)) {
    Write-Host "Java not found. Install JDK 21 and ensure it is in PATH or Program Files\Java\" -ForegroundColor Red
    exit 1
}
$env:JAVA_HOME = (Get-Item $JavaExe).Directory.Parent.FullName
Write-Host "Using Java: $JavaExe"

# Gradle: wrapper first, then system
$GradleCmd = $null
$gradlew = Join-Path $ProjectDir "gradlew.bat"
if (Test-Path $gradlew) { $GradleCmd = $gradlew }
if (-not $GradleCmd -and (Get-Command gradle -ErrorAction SilentlyContinue)) { $GradleCmd = "gradle" }
if (-not $GradleCmd) {
    Write-Host "Gradle not found. Use the Gradle wrapper (gradlew.bat) or install Gradle." -ForegroundColor Red
    exit 1
}

# Port check
$port = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($port) {
    Write-Host "Port 8080 in use by PID $($port.OwningProcess). Run: Stop-Process -Id $($port.OwningProcess) -Force" -ForegroundColor Yellow
    exit 1
}

Set-Location $ProjectDir
Write-Host "Running: $GradleCmd bootRun" -ForegroundColor Cyan
& $GradleCmd bootRun @args
