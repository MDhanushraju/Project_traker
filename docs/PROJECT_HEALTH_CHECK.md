# Project health check – APIs, requests, and flows

**Checked:** Backend controllers, services, frontend API calls, auth flow, config.  
**Live:** Render health endpoint verified UP; DB connected.

---

## 1. Backend APIs (all present and wired)

| # | Method | Endpoint | Controller | Service | Status |
|---|--------|----------|------------|---------|--------|
| 1 | GET | `/actuator/health` | (actuator) | - | ✓ CORS, permitAll |
| 2 | GET | `/` | RootController | - | ✓ |
| 3 | POST | `/api/auth/login` | AuthController | AuthService.login | ✓ |
| 4 | POST | `/api/auth/signup` | AuthController | AuthService.signUp | ✓ |
| 5 | POST | `/api/auth/login-with-role` | AuthController | AuthService.loginWithRole | ✓ |
| 6 | POST | `/api/auth/forgot-password` | AuthController | AuthService.forgotPassword | ✓ |
| 7 | POST | `/api/auth/verify-captcha` | AuthController | AuthService.verifyCaptcha | ✓ |
| 8 | POST | `/api/auth/reset-password` | AuthController | AuthService.resetPassword | ✓ |
| 9 | GET | `/api/projects` | ProjectController | ProjectService.findAll | ✓ |
| 10 | GET | `/api/tasks` | TaskController | TaskService.findAll / findByAssignedUser | ✓ |
| 11 | POST | `/api/tasks` | TaskController | TaskService.createTask | ✓ |
| 12 | PATCH | `/api/tasks/{id}/status` | TaskController | TaskService.updateStatus | ✓ |
| 13 | DELETE | `/api/tasks/{id}` | TaskController | TaskService.deleteTask | ✓ |
| 14 | POST | `/api/tasks/assign` | TaskController | TaskService.assignTask | ✓ |
| 15 | GET | `/api/users` | UserController | DataService.getAllUsers | ✓ |
| 16 | POST | `/api/users` | UserController | DataService.createUser | ✓ |
| 17 | PATCH | `/api/users/{id}/role` | UserController | DataService.assignRole | ✓ |
| 18 | GET | `/api/users/team-leader/projects` | UserController | DataService.getTeamLeaderAssignedProjects | ✓ |
| 19 | GET | `/api/users/team-leader/team-members` | UserController | DataService.getTeamLeaderTeamMembers | ✓ |
| 20 | GET | `/api/users/team-leader/team-manager` | UserController | DataService.getTeamManager | ✓ |
| 21 | GET | `/api/users/member/projects` | UserController | DataService.getMemberAssignedProjects | ✓ |
| 22 | GET | `/api/users/member/contacts` | UserController | DataService.getMemberContacts | ✓ |

---

## 2. Frontend → backend mapping

| Frontend (file) | Calls | Backend endpoint | Match |
|-----------------|-------|------------------|-------|
| auth_service.dart | login | POST /api/auth/login | ✓ |
| auth_service.dart | signUp | POST /api/auth/signup | ✓ |
| auth_service.dart | loginWithRole | POST /api/auth/login-with-role | ✓ |
| forgot_password_page.dart | - | POST /api/auth/forgot-password | ✓ |
| forgot_password_otp_page.dart | - | POST /api/auth/verify-captcha | ✓ |
| reset_password_page.dart | - | POST /api/auth/reset-password | ✓ |
| api_repository.dart | getProjects | GET /api/projects | ✓ |
| api_repository.dart | getTasks | GET /api/tasks | ✓ |
| api_repository.dart | getTeamLeaderProjects | GET /api/users/team-leader/projects | ✓ |
| api_repository.dart | getTeamLeaderTeamMembers | GET /api/users/team-leader/team-members | ✓ |
| api_repository.dart | getTeamManager | GET /api/users/team-leader/team-manager | ✓ |
| api_repository.dart | getMemberProjects | GET /api/users/member/projects | ✓ |
| api_repository.dart | getMemberContacts | GET /api/users/member/contacts | ✓ |
| api_repository.dart | createUser | POST /api/users | ✓ |
| api_repository.dart | assignRole | PATCH /api/users/{id}/role | ✓ |
| api_repository.dart | getAllUsers | GET /api/users | ✓ |
| api_repository.dart | createTask | POST /api/tasks | ✓ |
| api_repository.dart | updateTaskStatus | PATCH /api/tasks/{id}/status | ✓ |
| api_repository.dart | deleteTask | DELETE /api/tasks/{id} | ✓ |
| api_repository.dart | assignTask | POST /api/tasks/assign | ✓ |
| user_api.dart | - | GET /api/users, team-leader/*, member/* | ✓ |

All frontend API calls use the same paths and methods as the backend.

---

## 3. Response shape handling

| Backend returns | Frontend expects | Status |
|-----------------|------------------|--------|
| Auth: ApiResponse&lt;AuthResponse&gt; (token, role, email, fullName) | data.token, data.role → TokenManager + AuthState | ✓ |
| Projects: List&lt;ProjectDto&gt; (raw array) | res is List ? res : res['data'] | ✓ |
| Tasks: List&lt;TaskDto&gt; (raw array) | same | ✓ |
| Users: ApiResponse&lt;List&gt; (data = list) | res['data'] | ✓ |
| UserController sub-routes: ApiResponse with data | res['data'] | ✓ |
| DELETE task: 204 No Content | no body; success = no exception | ✓ |

---

## 4. Auth and security

| Item | Status |
|------|--------|
| JwtAuthFilter skips /api/auth/** | ✓ |
| Protected routes require Bearer token | ✓ |
| ApiClient adds Authorization from TokenManager | ✓ |
| CORS on all responses (filter + security) | ✓ |
| AuthException → 400, UnauthorizedException → 401 | ✓ |
| Signup/login wrapped so no 500 leak | ✓ |

---

## 5. Config and deployment

| Item | Status |
|------|--------|
| application.yml: PORT, DATABASE_URL, JWT_SECRET | ✓ |
| DatabaseUrlInitializer for Render postgresql:// → jdbc | ✓ |
| server.address 0.0.0.0 for Render | ✓ |
| Frontend: API_BASE_URL, fallback to localhost | ✓ |
| Dockerfile: Java 21, bootJar, PORT from env | ✓ |

---

## 6. Live check (Render)

- **GET /actuator/health** → 200, `"status":"UP"`, `"db":{"status":"UP"}` ✓

---

## 7. How to run a full request test

1. **PowerShell (all key requests):**
   ```powershell
   .\scripts\test-all-apis.ps1
   ```
2. **Postman:** Use `docs/POSTMAN_FAKE_DATA.md` for every endpoint with fake data.
3. **Checklist:** Use `docs/API_CHECKLIST.md` to tick each request manually.

---

## Summary

- **Backend:** All 22 endpoints exist, use the right services, and return the expected shapes.
- **Frontend:** Every API call matches an endpoint; response handling matches backend (raw list vs ApiResponse).
- **Auth:** JWT filter, token injection, and error handling are consistent.
- **Config:** App and Docker configs support local run and Render; DB and health are verified.

The project is wired correctly end-to-end. Any remaining issues are likely environment-specific (e.g. wrong URL, missing env vars) or data-specific (e.g. validation/400 on signup). Use the script or Postman to hit every request and confirm.
