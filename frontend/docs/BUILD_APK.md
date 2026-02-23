# Build Flutter App as APK

## If `flutter doctor` shows Android issues

**1. Accept Android licenses:**
```powershell
flutter doctor --android-licenses
```
Type `y` for each prompt.

**2. If "cmdline-tools component is missing":**  
Open **Android Studio** → **Settings** (Ctrl+,) → **Languages & Frameworks** → **Android SDK** → **SDK Tools** tab → check **Android SDK Command-line Tools (latest)** → **Apply**.  
Or install from: https://developer.android.com/studio#command-line-tools-only and set `ANDROID_HOME` to the SDK path.

**3. Run again:**
```powershell
flutter doctor
```

---

## If you see "Failed to install... NDK (Side by side)"

The build needs the **Android NDK**. Install it:

1. Open **Android Studio**.
2. **File → Settings** (or **Ctrl+,**) → **Languages & Frameworks → Android SDK**.
3. Open the **SDK Tools** tab.
4. Check **NDK (Side by side)** and ensure the version matches (e.g. **28.2.13676358**). If you see **Show Package Details**, open it and select the exact version the error asks for.
5. Click **Apply** and wait for the install to finish (can be large).
6. Run again: `cd d:\Project_traker\frontend` then `flutter build apk --release`.

---

## If you see "No Android SDK found"

Set **ANDROID_HOME** so Flutter can find the Android SDK.

**1. Find your Android SDK path**

- If you use **Android Studio:**  
  **File → Settings → Appearance & Behavior → System Settings → Android SDK**  
  Copy the path at the top (e.g. `C:\Users\YourName\AppData\Local\Android\Sdk`).
- Default on Windows: `C:\Users\<YourUsername>\AppData\Local\Android\Sdk`

**2. Set it for the current terminal (PowerShell):**
```powershell
$env:ANDROID_HOME = "C:\Users\91741\AppData\Local\Android\Sdk"
# If you have cmdline-tools in the SDK:
$env:PATH = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:PATH"
```

**3. Build again:**
```powershell
cd d:\Project_traker\frontend
flutter build apk --release
```

**To set ANDROID_HOME permanently (Windows):**  
**Settings → System → About → Advanced system settings → Environment Variables** → New **User** or **System** variable:  
Name `ANDROID_HOME`, Value = your SDK path (e.g. `C:\Users\91741\AppData\Local\Android\Sdk`). Restart the terminal.

**If you don’t have the SDK:** Install [Android Studio](https://developer.android.com/studio) and complete setup; it installs the SDK. Then run `flutter doctor` to confirm.

---

## If you see "deleted Android v1 embedding"

Your Android project may be outdated. Regenerate it (v2 embedding):

```powershell
cd d:\Project_traker\frontend
flutter create . --platforms=android
```

Then build again: `flutter build apk --release`.

---

## Build using D: drive (avoid C: disk space)

Gradle normally uses `C:\Users\<you>\.gradle`. To use **D:** instead:

**Option 1 – script (recommended):**
```powershell
cd d:\Project_traker\frontend
.\build-apk-on-d.ps1
```

**Option 2 – manual:**
```powershell
$env:GRADLE_USER_HOME = "D:\gradle-home"
cd d:\Project_traker\frontend
flutter build apk --release
```

Gradle caches and the wrapper will then use `D:\gradle-home` instead of C:.

---

## Prerequisites

- Flutter SDK installed
- Android SDK installed (Android Studio or command-line tools)
- Run from the **frontend** folder

## Build APK (debug – quick)

```powershell
cd d:\Project_traker\frontend
flutter pub get
flutter build apk --debug
```

**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

---

## Build APK (release – for distribution)

```powershell
cd d:\Project_traker\frontend
flutter pub get
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## Build App Bundle (AAB – for Play Store)

```powershell
cd d:\Project_traker\frontend
flutter pub get
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## One-line commands

| Type   | Command |
|--------|---------|
| Debug APK  | `flutter build apk --debug` |
| Release APK | `flutter build apk --release` |
| Release AAB | `flutter build appbundle --release` |

---

## If you see "There is not enough space on the disk"

Gradle needs several hundred MB free. Free space, then retry.

1. **Empty Recycle Bin.**
2. **Delete Flutter build artifacts** (safe; Flutter recreates them):
   ```powershell
   cd d:\Project_traker\frontend
   Remove-Item -Recurse -Force build, .dart_tool -ErrorAction SilentlyContinue
   ```
3. **Clear Gradle caches** (optional; frees a lot, but next build will re-download):
   ```powershell
   Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches -ErrorAction SilentlyContinue
   ```
4. Free more space on the drive (usually C:) by moving or deleting other files.

Then run `flutter build apk --release` again.

---

## If you see "There is not enough space on the disk" (Kotlin daemon / executionHistory)

Builds write to **C:** as well (Flutter SDK is under `C:\Users\...\OneDrive\...\flutter\`). Free space on **C:** then retry.

**1. Free space on C:**
- Empty Recycle Bin.
- Delete `frontend\build` and `frontend\.dart_tool`:  
  `Remove-Item -Recurse -Force d:\Project_traker\frontend\build, d:\Project_traker\frontend\.dart_tool -ErrorAction SilentlyContinue`
- In **Settings → Storage**, free space on C: (e.g. Temporary files, uninstall apps).

**2. Use D: for Gradle and do a clean build:**
```powershell
cd d:\Project_traker\frontend
.\build-apk-on-d.ps1
```
(This sets `GRADLE_USER_HOME=D:\gradle-home`, runs `flutter clean`, then builds.)

**3. If it still fails:** Your **Flutter SDK** is on C: (OneDrive). Move Flutter to **D:** (e.g. `D:\flutter`) and add `D:\flutter\bin` to PATH so all build output uses D: and C: is not filled.

---

## If you see "insufficient memory" or "paging file is too small"

Gradle was trying to use too much RAM (e.g. 8GB). It’s now limited in `android/gradle.properties` to 1.5GB heap. If you still get memory errors:

1. Close other apps to free RAM.
2. Increase Windows virtual memory: **Settings → System → About → Advanced system settings → Performance Settings → Advanced → Virtual memory → Change** → set a larger paging file on D: (e.g. 4096 MB).
3. Or lower further: in `frontend/android/gradle.properties` set `org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=256m`.

---

## Notes

- **Debug APK:** Larger, easier to install for testing; no signing needed.
- **Release APK:** Smaller, needs a signing key. First time: `flutter build apk --release` may prompt to create a keystore, or configure `android/key.properties` and `android/app/build.gradle` for signing.
- On a real device or emulator, backend URL may need to be `http://10.0.2.2:8080` (Android emulator) or your machine’s IP; see `lib/app/app_config.dart`.
