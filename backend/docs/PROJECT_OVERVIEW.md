# Project Tracker — What You Built & Technologies Used

## What You Did in This Project

You built a **full-featured Flutter project tracker app** with the following:

### 1. **App shell & entry**
- **main.dart** — Entry point with `WidgetsFlutterBinding.ensureInitialized()`, async `AppInitializer.init()` (session restore), and `runZonedGuarded` for error handling.
- **App** — `MaterialApp` with guarded routes, light/dark theme, and named routing (Login, Dashboard, Projects, Tasks, Settings).

### 2. **Authentication & authorization**
- **Login** — Role-based sign-in (Admin, Manager, Member) with loading state; token and role stored via `AuthService`.
- **Token flow** — Login → (mock) API → JWT stored → `AuthState` updated → redirect to Dashboard/Tasks.
- **Session restore** — On app start, `AppInitializer` calls `AuthService.restoreSession()` so **refresh keeps you logged in**.
- **Auth guard** — Every route is checked: not logged in → redirect to Login; logged in → role decides access (Admin: all, Manager: dashboard/projects/tasks/settings, Member: tasks only).
- **Storage** — Web uses localStorage (SharedPreferences); mobile/iOS use secure storage. **UI never touches storage**; only `AuthService` and `TokenManager` do.

### 3. **Responsive layout**
- **MainLayout** — One shell for all protected pages; content injected as `child`.
- **Web/Desktop (≥600px)** — Sidebar (`NavigationRail`) on the left, content on the right.
- **Mobile (<600px)** — App bar with menu, **Drawer** for nav + user + logout, **Bottom navigation bar** for quick switch.
- **Breakpoint** — 600px; resizing the browser switches layout.

### 4. **Theme system**
- **Single seed color** — `AppColors.seedColor` in `lib/shared/theme/colors.dart`. Change it once → whole app updates.
- **No hardcoded colors** in feature widgets; all use `Theme.of(context).colorScheme` and `theme.textTheme`.
- **Apple-style** — Soft shadows (`AppShadows`), neutral surfaces, typography scale in `AppTextStyles`.

### 5. **Screens & UI**
- **Login** — Gradient background, role cards with loading spinner, token stored on tap.
- **Dashboard** — Welcome text, stat cards (Projects, Tasks, Overdue), Active projects list, Upcoming tasks, “See all” links to Projects/Tasks.
- **Projects** — List of project cards with **progress bar** and status; empty state with “Add project” CTA.
- **Tasks** — Filter chips (All, To do, In progress, Done), task cards with **status icon** and **due date**; empty state with “Add task” CTA.
- **Settings** — User card, Management sections (User, Client, Project settings) as list tiles in cards.
- **Shared** — Empty state (optional action button), FadeIn animations, consistent cards (16px radius, borders).

### 6. **Data & structure**
- **Mock data** — Projects (name, status, progress), tasks (title, status, dueDate) in `lib/data/mock_data.dart`; ready to replace with API.
- **Models** — `ProjectModel`, `TaskModel`, `SubtaskModel`, `TeamModel`; controllers and services stubbed per module.
- **Constants** — Roles, task status, app constants; single source for route–role rules in `RoleAccess`.

### 7. **Code quality & tooling**
- **Extensions** — Context (theme, colorScheme, textTheme), String (isBlank), DateTime (toDateString), List (firstOrNull), num (pad).
- **Validators & utils** — Email/required validators, debounce, date formatting.
- **VS Code/Cursor** — `.vscode/extensions.json` with recommended extensions (Flutter, Dart, Error Lens, GitLens, REST Client, etc.).
- **Linting** — `flutter_lints` and `analysis_options.yaml`.

---

## Technologies Used

| Category | Technology |
|----------|------------|
| **Framework** | **Flutter** (SDK ≥3.0) |
| **Language** | **Dart** |
| **UI** | **Material 3** (Material Design 3), Flutter widgets |
| **State** | **ChangeNotifier** (e.g. `AuthState`, controllers), no external state package |
| **Routing** | **Named routes** + `onGenerateRoute` with `AuthGuard` |
| **Storage (Web)** | **shared_preferences** (localStorage) |
| **Storage (Mobile/iOS)** | **flutter_secure_storage** (encrypted) |
| **Theme** | Custom theme layer: `AppColors`, `AppTextStyles`, `AppShadows`, `AppTheme` (ColorScheme.fromSeed) |
| **Linting** | **flutter_lints** |
| **Platforms** | **Web**, **iOS**, **Android** (Flutter multi-platform) |

### Dependencies (pubspec.yaml)

- **flutter** — SDK.
- **shared_preferences** — Key-value storage (web → localStorage).
- **flutter_secure_storage** — Secure key-value storage (mobile/iOS/Android).
- **flutter_lints** — Dev dependency for analysis rules.

### Project structure

- **lib/app/** — App widget, config, routes, theme, initializer.
- **lib/core/** — Auth (service, guard, state, token, role_access, storage), network stubs, state, constants, utils, extensions.
- **lib/modules/** — dashboard, projects, tasks, teams, settings, auth (login, forgot password).
- **lib/shared/** — layouts (main_layout, sidebar, mobile_nav), theme (colors, text_styles, shadows), widgets, animations.
- **lib/data/** — Mock data (replace with API later).

---

## Summary

You implemented a **production-style Flutter app** with:

- **Real auth flow** (login, JWT storage, session restore, logout) and **role-based routing**.
- **Responsive layout** (sidebar on desktop, drawer + bottom nav on mobile).
- **Centralized theme** (one seed color, no hardcoded colors in UI).
- **Full UI** for Dashboard, Projects, Tasks, Settings, and Login, with mock data and clear structure for wiring a real API later.

**Technologies:** Flutter, Dart, Material 3, shared_preferences, flutter_secure_storage, and a small set of core utilities and extensions.
