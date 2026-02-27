# API checklist – verify every request

**Base URL:** `https://project-traker-backend.onrender.com`

## Quick automated test (PowerShell)

From the project root run:

```powershell
.\scripts\test-all-apis.ps1
```

To test against local backend:

```powershell
.\scripts\test-all-apis.ps1 -BaseUrl "http://localhost:8080"
```

The script tests: health, root, login, login-with-role, forgot-password, (with token) projects, tasks, users, create task, team-leader/member endpoints, and signup. It prints OK/FAIL for each.

---

## Manual check (Postman or browser)

| # | Method | Endpoint | Auth | Expected |
|---|--------|----------|------|----------|
| 1 | GET | `/actuator/health` | No | 200, `"status":"UP"` |
| 2 | GET | `/` | No | 200, Swagger UI |
| 3 | POST | `/api/auth/login` | No | 200, `data.token` |
| 4 | POST | `/api/auth/signup` | No | 200 or 400 |
| 5 | POST | `/api/auth/login-with-role` | No | 200, `data.token` |
| 6 | POST | `/api/auth/forgot-password` | No | 200 |
| 7 | POST | `/api/auth/verify-captcha` | No | 200 (with correct answer) |
| 8 | POST | `/api/auth/reset-password` | Bearer reset_token | 200 |
| 9 | GET | `/api/projects` | Bearer token | 200 |
| 10 | GET | `/api/tasks` | Bearer token | 200 |
| 11 | POST | `/api/tasks` | Bearer token | 200/201 |
| 12 | PATCH | `/api/tasks/{id}/status` | Bearer token | 200 |
| 13 | DELETE | `/api/tasks/{id}` | Bearer token | 200 |
| 14 | POST | `/api/tasks/assign` | Bearer token | 200 |
| 15 | GET | `/api/users` | Bearer token | 200 |
| 16 | POST | `/api/users` | Bearer token | 200/201 |
| 17 | PATCH | `/api/users/{id}/role` | Bearer token | 200 |
| 18 | GET | `/api/users/team-leader/projects` | Bearer token | 200 |
| 19 | GET | `/api/users/team-leader/team-members` | Bearer token | 200 |
| 20 | GET | `/api/users/team-leader/team-manager` | Bearer token | 200 |
| 21 | GET | `/api/users/member/projects` | Bearer token | 200 |
| 22 | GET | `/api/users/member/contacts` | Bearer token | 200 |

**Order:** Call 3 (login) or 4 (signup) first to get a token, then use that token for 9–22.

---

## Verified (live check)

- **GET /actuator/health** – OK, status UP, DB UP
- **GET /** – OK, Swagger UI
- **GET /swagger-ui.html** – OK, API overview and test credentials

POST/PATCH/DELETE need a client (Postman or the script above).
