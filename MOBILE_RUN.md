# Mobile Run — Commands Cheatsheet

Commands for running the Flutter app on Android, building APK, backend, and PostgreSQL.

---

## 1. PostgreSQL

**Start (Windows, if installed as service):**
```powershell
# If using Windows Service:
net start postgresql-x64-16
# or (version may vary):
net start postgresql
```

**Check if running:**
```powershell
Get-Service -Name "postgresql*"
# or
psql -U postgres -c "SELECT 1"
```

**Start via Docker (if using):**
```powershell
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=Dhanush@03 postgres:16
```

---

## 2. Backend (Spring Boot)

**Run:**
```powershell
cd D:\Project_traker\backend
.\gradlew.bat bootRun
# or
.\run-backend.ps1
```

**Stop:** Press `Ctrl+C` in the terminal.

**Build JAR (no run):**
```powershell
cd D:\Project_traker\backend
.\gradlew.bat clean build -x test
```

---

## 3. ADB (Android Debug Bridge)

**Forward port so device/emulator can reach backend:**
```powershell
adb reverse tcp:8080 tcp:8080
```

**List reverse forwards:**
```powershell
adb reverse --list
```

**List devices:**
```powershell
adb devices
```

**Remove reverse:**
```powershell
adb reverse --remove tcp:8080
```

---

## 4. Flutter Run (Development)

**Run on connected device/emulator:**
```powershell
cd D:\Project_traker\frontend
flutter run
```

**Run on Chrome (web):**
```powershell
flutter run -d chrome
```

**Run on specific device:**
```powershell
flutter devices
flutter run -d <device-id>
```

**Enable web/windows if needed:**
```powershell
flutter create . --platforms=android,web,windows
```

---

## 5. Build APK

**Release APK:**
```powershell
cd D:\Project_traker\frontend
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

**Debug APK (faster):**
```powershell
flutter build apk --debug
```

---

## 6. Full Mobile Run (Typical Order)

1. **PostgreSQL** — ensure DB is running  
2. **Backend** — `cd backend; .\gradlew.bat bootRun` (in one terminal)  
3. **ADB reverse** — `adb reverse tcp:8080 tcp:8080` (once per emulator/device session)  
4. **Flutter run** — `cd frontend; flutter run` (in another terminal)  
5. Use the app — it will connect to backend via `localhost:8080` thanks to ADB reverse  

---

## 7. One-Time Setup

| Task | Command |
|------|---------|
| Flutter doctor | `flutter doctor` |
| Accept Android licenses | `flutter doctor --android-licenses` |
| Add platforms | `cd frontend; flutter create . --platforms=android,web,windows` |
