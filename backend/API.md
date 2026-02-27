# Project Tracker — API Reference

Base URL: **http://localhost:8080**

All JSON responses use this shape:
- **Success:** `{ "success": true, "message": "...", "data": {...}, "statusCode": 200 }`
- **Error:** `{ "success": false, "message": "...", "data": null, "statusCode": 4xx, "errorCode": "...", "path": "/api/..." }`

Use **Content-Type: application/json** for requests with a body.

---

## 1. Health (no auth)

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/health/db` | Check database connection. Returns `database: "connected"` or 503 if DB is down. |

**Example**
```http
GET http://localhost:8080/api/health/db
```

**Success (200)**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OK",
  "data": {
    "database": "connected"
  }
}
```

---

## 2. Auth (Login, Sign up, Forgot password, Reset password)

### Log In
Matches the **Log In** screen: Email Address, Password, ID Card Number (optional).

```http
POST http://localhost:8080/api/auth/login
Content-Type: application/json
```
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03"
}
```
With optional ID card (when provided, user must match both email and idCardNumber):
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03",
  "idCardNumber": "000-0000-001"
}
```
**Success (200):** `data` contains `id`, `role`, `email`, `fullName`, `position`. Passwords are stored hashed (BCrypt). No auth header required for other APIs.

### Forgot password
Server returns a simple math question (e.g. "What is 2 + 8?"). User must answer correctly on reset-password to set a new password (stored hashed).

```http
POST http://localhost:8080/api/auth/forgot-password
Content-Type: application/json
```
```json
{ "email": "admin@taker.com" }
```
**Success (200):** `data.message` and `data.captchaQuestion` (e.g. "What is 2 + 8?"). Answer is valid for 5 minutes.

### Reset password
Send same email + correct answer (e.g. `10`) + new password. New password is stored **hashed** (BCrypt).

```http
POST http://localhost:8080/api/auth/reset-password
Content-Type: application/json
```
```json
{
  "email": "admin@taker.com",
  "captchaAnswer": "10",
  "newPassword": "NewPass@1",
  "confirmPassword": "NewPass@1"
}
```
**Success (200):** Password updated. User can log in with the new password.

### Sign up (Join Taker)
Matches the **Join Taker** form: Full Name, Email Address, ID Card Number, Password, Confirm Password, role dropdown, team dropdown.

```http
POST http://localhost:8080/api/auth/signup
Content-Type: application/json
```
```json
{
  "fullName": "Jane Doe",
  "email": "jane@example.com",
  "idCardNumber": "000-0000-005",
  "password": "secret",
  "confirmPassword": "secret",
  "role": "member",
  "position": "Developer"
}
```
You can send **team** instead of **position** (same meaning): `"team": "Developer"`.  
**Roles:** admin, manager, team_leader, member.  
**Team/position:** Developer, Tester, Designer, Analyst.  
**Success (200):** `data` contains `id`, `role`, `email`, `fullName`, `position`. Token is empty.

---

## 3. APIs (no auth for now)

All endpoints are open. No `Authorization` header required.

### Projects
| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/projects` | List all projects. |

**Example**
```http
GET http://localhost:8080/api/projects
```
**Success (200):** `data` is an array of `{ "id", "name", "status", "progress" }`.

### Tasks
| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/tasks` | List all tasks. Optional: `?userId=3` to filter by assigned user. |
| POST | `/api/tasks` | Create task. Body: `title`, `status` (optional), `dueDate` (optional). |
| PATCH | `/api/tasks/{id}/status` | Update task status. Body: `status` (e.g. need_to_start, ongoing, completed). |
| DELETE | `/api/tasks/{id}` | Delete task. Returns 204. |
| POST | `/api/tasks/assign` | Assign task. Body: `userId`, `taskTitle`, `dueDate` (optional), `projectId` (optional). |

**Example — list tasks**
```http
GET http://localhost:8080/api/tasks
```

**Example — create task**
```http
POST http://localhost:8080/api/tasks
Content-Type: application/json
```
```json
{ "title": "Implement login UI", "status": "need_to_start" }
```

### Users
| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/users` | List all users (id, fullName, email, role, position). |
| POST | `/api/users` | Create user (Admin/Manager). Body: fullName, email, password, role, position (optional). |
| PATCH | `/api/users/{id}/role` | Assign role (Admin/Manager). Body: role, position (optional). |
| GET | `/api/users/team-leader/projects` | Team leader: my assigned projects. |
| GET | `/api/users/team-leader/team-members` | Team leader: team members by project. |
| GET | `/api/users/team-leader/team-manager` | Team leader: my manager. |
| GET | `/api/users/member/projects` | Member: my assigned projects. |
| GET | `/api/users/member/contacts` | Member: contacts (manager, leader, members). |

**Example — list users**
```http
GET http://localhost:8080/api/users
```

---

## Quick test order

1. **GET** `/api/health/db` → should return 200 and `database: "connected"`.
2. **POST** `/api/auth/signup` with the signup JSON above → 200 and user info (token empty).
3. **GET** `/api/projects` → 200 and list of projects (may be empty).
4. **GET** `/api/tasks` → 200 and list of tasks.

Swagger UI (when backend is running): **http://localhost:8080/swagger-ui.html**
