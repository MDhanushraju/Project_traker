# Backend APIs for Frontend

All success responses: `{ "statusCode": 200, "success": true, "message": "...", "data": ... }`.

**Error responses** include a clean message, an error code (where it failed), and the request path:
```json
{
  "statusCode": 400,
  "success": false,
  "message": "Email already registered.",
  "data": null,
  "errorCode": "auth.signup_email_exists",
  "path": "/api/auth/signup"
}
```
- **errorCode** – identifies exactly where it failed (see list below).
- **path** – the API path that failed (e.g. `/api/auth/login`).
- **message** – human-readable message.
- For validation errors, **data** may contain a map of `field -> error message`.

### Error codes (errorCode)

| Code | Meaning |
|------|--------|
| auth.login_failed | Login (email/password) failed |
| auth.signup_failed | Sign up validation or business rule failed |
| auth.signup_email_exists | Email already registered |
| auth.login_with_role_failed | No user found for the given role |
| auth.unauthorized | Not authorized (401) |
| auth.forgot_password | Forgot password request failed |
| auth.verify_captcha | Captcha verification failed |
| auth.reset_password | Password reset failed |
| validation.failed | Request validation failed (check **data** for field-level errors) |
| validation.request_body | Invalid JSON or missing required fields |
| data.email_exists | Email already registered (DB constraint) |
| data.invalid | Invalid data (DB/constraint) |
| user.not_found | User not found (404) |
| task.not_found | Task not found (404) |
| project.not_found | Project not found (404) |
| internal.error | Unexpected server error (500) |

Base URL: `http://localhost:8080` (no trailing slash).  
Auth: send `Authorization: Bearer <token>` for protected endpoints.

---

## Auth (no token required)

| Method | Path | Body | Response data |
|--------|------|------|----------------|
| POST | /api/auth/login | `{ "email", "password", "idCardNumber"? }` | `{ token, role, email, fullName }` |
| POST | /api/auth/signup | `{ fullName, email, password, confirmPassword, role, idCardNumber?, position? }` | `{ token, role, email, fullName }` |
| POST | /api/auth/login-with-role | `{ "role": "admin" \| "manager" \| "team_leader" \| "member" }` | `{ token, role, email, fullName }` |
| POST | /api/auth/forgot-password | `{ "email" }` | `{ captchaQuestion }` |
| POST | /api/auth/verify-captcha | `{ "email", "captchaAnswer" }` | `{ resetToken }` |
| POST | /api/auth/reset-password | `{ newPassword, confirmPassword }` | Header: `Authorization: Bearer <reset_token>` |

---

## Projects (auth required)

| Method | Path | Response data |
|--------|------|----------------|
| GET | /api/projects | `[ { id, name, status, progress } ]` |

---

## Tasks (auth required)

| Method | Path | Body | Response |
|--------|------|------|----------|
| GET | /api/tasks | - | `[ { id, title, status, dueDate } ]` |
| GET | /api/tasks?userId=3 | - | tasks for that user |
| POST | /api/tasks | `{ title, status?, dueDate? }` | task object in `data` |
| PATCH | /api/tasks/{id}/status | `{ "status": "need_to_start" \| "ongoing" \| "completed" }` | task in `data` |
| DELETE | /api/tasks/{id} | - | 204 No Content |
| POST | /api/tasks/assign | `{ userId, taskTitle, dueDate?, projectId? }` | task in `data` |

---

## Users (auth required)

| Method | Path | Body | Response data |
|--------|------|------|----------------|
| GET | /api/users | - | `[ { id, name, title, role, position, temporary } ]` |
| POST | /api/users | `{ fullName, email, password?, role, position?, title?, temporary? }` | user object |
| PATCH | /api/users/{id}/role | `{ role, position? }` | user object |
| GET | /api/users/team-leader/projects | - | `[ "Project A", "Project B" ]` |
| GET | /api/users/team-leader/team-members | - | `{ "Project A": [ { id, name, title, position } ], ... }` |
| GET | /api/users/team-leader/team-manager | - | `{ name, title }` |
| GET | /api/users/member/projects | - | `[ "Project A", ... ]` |
| GET | /api/users/member/contacts | - | `[ { name, title, type } ]` |

---

Roles: `admin`, `manager`, `team_leader`, `member` (frontend may send `teamLeader`; backend accepts both).  
Task status: `need_to_start`, `ongoing`, `completed`.
