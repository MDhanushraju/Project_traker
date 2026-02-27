# Swagger / OpenAPI Documentation

## Quick access

| What | URL |
|------|-----|
| **Swagger UI** (interactive docs) | **http://localhost:8080/swagger-ui/index.html** |
| Alternative | http://localhost:8080/swagger-ui.html |
| **OpenAPI JSON** (raw spec) | http://localhost:8080/v3/api-docs |
| **Root** (redirects to Swagger UI) | http://localhost:8080/ |

1. Start the backend: `.\gradlew bootRun` (port 8080).
2. Open **http://localhost:8080/swagger-ui/index.html** in your browser.

---

## API overview

### Auth (no token)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/login` | Log in with **email** or **loginId** (5-digit) + password. Returns user + role. |
| POST | `/api/auth/signup` | Register: fullName, email, password, confirmPassword, role, position. Returns user + **loginId** (5-digit). |
| POST | `/api/auth/forgot-password` | Send **email** or **loginId**; returns verification question (math). |
| POST | `/api/auth/reset-password` | Body: email, captchaAnswer, newPassword, confirmPassword. Resets password. |

### Users (Admin / Manager)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/users` | List all users (id, name, role, email, loginId, photoUrl, age, skills, currentProject, projectsCompletedCount). |
| GET | `/api/users/{id}` | Get one user by ID (full details). |
| POST | `/api/users` | Create user (fullName, email, password?, role, position?, title?, temporary?). |
| PATCH | `/api/users/{id}/role` | Assign/change role (role, position?). Promote/Demote. |
| PATCH | `/api/users/{id}/profile` | Update profile: photoUrl, age, skills (all optional). |
| GET | `/api/users/team-leader/projects` | Team Leader: my projects. |
| GET | `/api/users/team-leader/team-members` | Team Leader: team members by project. |
| GET | `/api/users/team-leader/team-manager` | Team Leader: my manager. |
| GET | `/api/users/member/projects` | Member: my projects. |
| GET | `/api/users/member/contacts` | Member: contacts (Manager, Team Leader, members). |

### Projects

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/projects` | List projects. |

### Tasks

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/tasks` | List tasks. |
| POST | `/api/tasks` | Create task (title, status?, dueDate?). |
| PATCH | `/api/tasks/{id}/status` | Update task status (need_to_start, ongoing, completed). |
| DELETE | `/api/tasks/{id}` | Delete task. |
| POST | `/api/tasks/assign` | Assign task (userId, taskTitle, dueDate?, projectId?). |

---

## How to test in Swagger UI

### 1. Get a token (optional for Auth only)

- **Auth** → **POST /api/auth/login**
- **Try it out**
- Body (email or loginId):
  ```json
  {
    "email": "admin@taker.com",
    "password": "Dhanush@03"
  }
  ```
  Or with 5-digit ID:
  ```json
  {
    "loginId": 10001,
    "password": "Dhanush@03"
  }
  ```
- **Execute** → copy `data.token` (or use without token; backend may return empty token and use role).

### 2. Authorize (if your APIs expect a token)

- Click **Authorize** (top right).
- Value: `Bearer <your_token>`
- **Authorize** → **Close**.

### 3. Call other endpoints

- Use **Users**, **Projects**, **Tasks**; click **Try it out**, edit body if needed, **Execute**.

---

## Test credentials (DataLoader seeds)

| Role        | Email              | Password   |
|-------------|--------------------|-----------|
| Admin       | admin@taker.com    | Dhanush@03 |
| Manager     | manager@taker.com  | Password@1 |
| Team Leader | leader@taker.com   | Password@1 |
| Team Member | member@taker.com   | Password@1 |

*(Login may return a 5-digit `loginId`; you can use that or email to log in.)*

---

## OpenAPI (JSON) spec

- **URL:** http://localhost:8080/v3/api-docs  
- Use this URL in Postman (Import → Link), or to generate clients.

---

## Summary

- **Swagger UI:** http://localhost:8080/swagger-ui/index.html  
- **OpenAPI JSON:** http://localhost:8080/v3/api-docs  
- Auth endpoints do not require authorization; Users/Projects/Tasks may use Bearer token if enabled.
