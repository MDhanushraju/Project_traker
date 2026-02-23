# Frontend API Schema

The frontend talks to the **backend REST API**. Full docs are in the backend Swagger UI.

## Backend API Docs (Swagger)

| Resource | URL |
|----------|-----|
| **Swagger UI** | http://localhost:8080/swagger-ui.html |
| **OpenAPI JSON** | http://localhost:8080/v3/api-docs |

Run the backend, then open the Swagger UI to view and try all endpoints.

---

## API Base URL

```
http://localhost:8080
```

Configured in `lib/app/app_config.dart` as `AppConfig.apiBaseUrl`.

---

## Endpoints Used by Frontend

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/login` | No | Login, returns JWT |
| POST | `/api/auth/signup` | No | Sign up |
| POST | `/api/auth/forgot-password` | No | Forgot password |
| POST | `/api/auth/verify-captcha` | No | Verify captcha |
| POST | `/api/auth/reset-password` | Bearer | Reset password |
| POST | `/api/auth/login-with-role` | No | Demo login by role |
| GET | `/api/projects` | Bearer | List projects |
| GET | `/api/tasks` | Bearer | List tasks |
| GET | `/api/tasks?userId=N` | Bearer | Tasks by user |
| POST | `/api/tasks` | Bearer | Create task |
| PATCH | `/api/tasks/{id}/status` | Bearer | Update task status |
| DELETE | `/api/tasks/{id}` | Bearer | Delete task |
| POST | `/api/tasks/assign` | Bearer | Assign task |
| GET | `/api/users` | Bearer | List users |
| POST | `/api/users` | Bearer | Create user |
| PATCH | `/api/users/{id}/role` | Bearer | Assign role |

---

## Request / Response Schema (OpenAPI)

The backend exposes OpenAPI 3.0 at:

```
GET http://localhost:8080/v3/api-docs
```

Use this JSON to generate clients, mock servers, or docs.
