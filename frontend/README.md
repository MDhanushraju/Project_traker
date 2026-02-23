# Project Tracker — Frontend (Flutter)

Flutter UI for the Project Tracker app. Connects to backend at `http://localhost:8080`.

## How to run

| Option | Command |
|--------|---------|
| PowerShell script | `.\run-frontend.ps1` |
| Web (Chrome) | `flutter pub get; flutter run -d chrome` |
| Windows | `flutter run -d windows` |
| Android | `flutter run -d android` |
| iOS | `flutter run -d ios` |
| Linux | `flutter run -d linux` |
| macOS | `flutter run -d macos` |

## Build APK

```powershell
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`. See `docs/BUILD_APK.md`.

## API Schema

See `docs/API_SCHEMA.md` for endpoints and links to backend Swagger/OpenAPI.

## Structure

```
frontend/
├── lib/              # Dart source
├── test/
├── docs/             # PROJECT_OVERVIEW.md, API_SCHEMA.md
├── android/ ios/ web/ windows/ linux/ macos/
├── run-frontend.ps1  # Start script
└── pubspec.yaml
```
