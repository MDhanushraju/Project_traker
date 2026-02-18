# Project Tracker

Flutter project tracker app with auth, role-based routing, responsive layout, and theme system.

## What's included

- **Entry & app** – `main.dart` → `App` (MaterialApp), guarded routes (Login, Dashboard, Projects, Tasks).
- **Auth** – `AuthState`, `AuthGuard`, `RoleAccess`. Login by role (Admin / Manager / Member); routes protected by role.
- **Layout** – `MainLayout`, `Sidebar`, `MobileNav`. Web/desktop: sidebar; mobile: drawer + bottom nav. Breakpoint 600px.
- **Theme** – `AppColors`, `AppTextStyles`, `AppShadows`, `AppTheme`. Single seed in `lib/shared/theme/colors.dart`; change it to update the whole app.
- **Core** – constants (roles, task_status, app_constants), utils (validators, debounce, date), state (app_state, user_state, loading_state), network stubs (api_client, endpoints), extensions (context, string, date, list, num).
- **Modules** – Dashboard, Projects, Tasks use MainLayout; Login with role picker; stubs for Teams, Settings, Forgot password and feature widgets/models/controllers/services.

## Run

```bash
flutter pub get
flutter run
```

## Checkpoints

1. **Auth** – Toggle login (Admin / Manager / Member); Member is redirected from Dashboard/Projects to Tasks.
2. **Layout** – Resize browser; layout switches at 600px (sidebar vs drawer + bottom nav).
3. **Theme** – Change `AppColors.seedColor` in `lib/shared/theme/colors.dart`; whole app updates.

## Structure

```
lib/
  main.dart
  app/           – app, config, routes, theme, initializer
  core/          – auth, network, state, constants, utils, extensions
  modules/       – dashboard, projects, tasks, teams, settings, auth
  shared/        – layouts, theme, widgets, animations
  assets/        – icons, images, fonts (add files then uncomment in pubspec)
```

## Next steps

- Wire real API in `ApiClient`, `AuthService`, `AuthRepository`, `TokenManager`.
- Add Teams and Settings to routes and wrap with MainLayout.
- Populate Dashboard, Projects, Tasks from controllers/services.
