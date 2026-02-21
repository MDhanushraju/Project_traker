# Run Spring Boot backend with Maven
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
    # Try exact path first (common JDK 21 install location)
    $jdk21 = Join-Path ${env:ProgramFiles} "Java\jdk-21\bin\java.exe"
    if (Test-Path $jdk21) {
        $JavaExe = $jdk21
    }
}
if (-not $JavaExe) {
    $paths = @(
        "${env:ProgramFiles}\Java\jdk-21*\bin\java.exe",
        "${env:ProgramFiles}\Java\jdk-17*\bin\java.exe",
        "${env:ProgramFiles}\Eclipse Adoptium\jdk-21*\bin\java.exe",
        "${env:ProgramFiles}\Eclipse Adoptium\jdk-17*\bin\java.exe",
        "${env:ProgramFiles}\Microsoft\jdk-21*\bin\java.exe"
    )
    foreach ($p in $paths) {
        $resolved = Get-Item $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved) { $JavaExe = $resolved.FullName; break }
    }
}
if (-not $JavaExe -or -not (Test-Path $JavaExe)) {
    Write-Host "Java not found. Install JDK 21 (https://adoptium.net/) and ensure it is in Program Files\Java\" -ForegroundColor Red
    exit 1
}
$env:JAVA_HOME = (Get-Item $JavaExe).Directory.Parent.FullName
Write-Host "Using Java: $JavaExe"

# Maven: PATH or .mvn/maven
$MvnCmd = $null
if (Get-Command mvn -ErrorAction SilentlyContinue) { $MvnCmd = "mvn" }
if (-not $MvnCmd) {
    $mvnPath = Join-Path $ProjectDir ".mvn\maven\bin\mvn.cmd"
    if (Test-Path $mvnPath) { $MvnCmd = $mvnPath }
}
if (-not $MvnCmd) {
    Write-Host "Maven not found. Install Maven or run: mvn -N io.takari:maven:wrapper -Dmaven=3.9.6" -ForegroundColor Red
    exit 1
}

# Port check
$port = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($port) {
    Write-Host "Port 8080 in use by PID $($port.OwningProcess). Run: Stop-Process -Id $($port.OwningProcess) -Force" -ForegroundColor Yellow
    exit 1
}

Set-Location $ProjectDir
Write-Host "Running: $MvnCmd spring-boot:run" -ForegroundColor Cyan
& $MvnCmd spring-boot:run @args
