# Run Flutter frontend
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
flutter pub get
flutter run -d chrome @args
