# Build APK using D: drive for Gradle (avoids C: disk space)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# Use D: for Gradle caches and wrapper (saves space on C:)
$gradleHome = "D:\gradle-home"
if (-not (Test-Path $gradleHome)) { New-Item -ItemType Directory -Path $gradleHome -Force | Out-Null }
$env:GRADLE_USER_HOME = $gradleHome

# Stop old daemons (avoids lock / wrong memory settings)
if (Test-Path "android\gradlew.bat") {
    Push-Location android
    .\gradlew.bat --stop 2>$null
    Pop-Location
}

Write-Host "GRADLE_USER_HOME = $env:GRADLE_USER_HOME" -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    $apk = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apk) {
        Write-Host "APK: $((Resolve-Path $apk).Path)" -ForegroundColor Green
    }
}
