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

## Structure

```
frontend/
├── lib/              # Dart source
├── test/
├── docs/             # PROJECT_OVERVIEW.md
├── android/ ios/ web/ windows/ linux/ macos/
├── run-frontend.ps1  # Start script
└── pubspec.yaml
```
