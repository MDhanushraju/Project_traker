# Project Tracker – API list for Postman

**Base URL (Render):** `https://project-traker-backend.onrender.com`  
**Base URL (local):** `http://localhost:8080`

Use **Authorization: Bearer \<token\>** for all endpoints under **Auth required**. Get the token from **POST /api/auth/login** or **POST /api/auth/login-with-role**.

---

## 1. Auth (no token)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login with email + password |
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/forgot-password` | Request password reset (captcha) |
| POST | `/api/auth/verify-captcha` | Verify captcha, get reset token |
| POST | `/api/auth/reset-password` | Reset password (Bearer = reset token) |
| POST | `/api/auth/login-with-role` | Demo: get token for first user with role |

### POST /api/auth/login

**Body (JSON):**
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03",
  "idCardNumber": ""
}
```
- `idCardNumber` optional. Returns `token`, `role`, `email`, `fullName`.

---

### POST /api/auth/signup

**Body (JSON):**
```json
{
  "fullName": "Your Name",
  "email": "you@example.com",
  "password": "Password@1",
  "confirmPassword": "Password@1",
  "idCardNumber": "",
  "role": "member",
  "position": "Developer"
}
```
- `role`: `admin` \| `manager` \| `member` \| `team_leader`
- `position`: required for `team_leader` / `member` (e.g. Developer, Tester, Designer, Analyst)
- `idCardNumber` optional

---

### POST /api/auth/forgot-password

**Body (JSON):**
```json
{
  "email": "admin@taker.com"
}
```

---

### POST /api/auth/verify-captcha

**Body (JSON):** (use email + answer from forgot-password response)
```json
{
  "email": "admin@taker.com",
  "captchaId": "<from forgot-password>",
  "answer": "<your answer>"
}
```

---

### POST /api/auth/reset-password

**Headers:** `Authorization: Bearer <reset_token_from_verify-captcha>`

**Body (JSON):**
```json
{
  "newPassword": "NewPass@1",
  "confirmPassword": "NewPass@1"
}
```

---

### POST /api/auth/login-with-role

**Body (JSON):**
```json
{
  "role": "admin"
}
```
- `role`: `admin` \| `manager` \| `member` \| `team_leader`. Returns token for first user with that role.

---

## 2. Health & docs (no token)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/actuator/health` | Health check (DB, disk, etc.) |
| GET | `/actuator/info` | Info |
| GET | `/` | Redirect to Swagger |
| GET | `/swagger-ui.html` | Swagger UI |
| GET | `/v3/api-docs` | OpenAPI JSON |

---

## 3. Projects (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/projects` | List all projects |

**Headers:** `Authorization: Bearer <token>`

---

## 4. Tasks (Auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | List all tasks |
| GET | `/api/tasks?userId=3` | Tasks assigned to user 3 |
| POST | `/api/tasks` | Create task |
| PATCH | `/api/tasks/{id}/status` | Update task status |
| DELETE | `/api/tasks/{id}` | Delete task |
| POST | `/api/tasks/assign` | Assign task to user |

**Headers:** `Authorization: Bearer <token>`

### POST /api/tasks

**Body (JSON):**
```json
{
  "title": "Setup dev environment",
  "status": "need_to_start",
  "dueDate": "2025-03-15"
}
```
- `status`: e.g. `need_to_start`, `ongoing`, `completed`

### PATCH /api/tasks/{id}/status

**Body (JSON):**
```json
{
  "status": "ongoing"
}
```

### POST /api/tasks/assign

**Body (JSON):**
```json
{
  "taskId": 1,
  "userId": 3
}
```

---

## 5. Users (Auth required – Admin/Manager for create & assign)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| POST | `/api/users` | Create user (Admin/Manager) |
| PATCH | `/api/users/{id}/role` | Assign role (Admin/Manager) |
| GET | `/api/users/team-leader/projects` | Team Leader: my projects |
| GET | `/api/users/team-leader/team-members` | Team Leader: team members by project |
| GET | `/api/users/team-leader/team-manager` | Team Leader: my manager |
| GET | `/api/users/member/projects` | Member: my projects |
| GET | `/api/users/member/contacts` | Member: contacts |

**Headers:** `Authorization: Bearer <token>`

### POST /api/users

**Body (JSON):**
```json
{
  "fullName": "Jane Doe",
  "email": "jane@test.com",
  "role": "member",
  "position": "Developer",
  "isTemporary": false
}
```

### PATCH /api/users/{id}/role

**Body (JSON):**
```json
{
  "role": "team_leader",
  "position": "Tester"
}
```

---

## Postman setup

1. **Environment**
   - Variable `baseUrl` = `https://project-traker-backend.onrender.com` (or `http://localhost:8080`)
   - Variable `token` = (set from login response)

2. **Login once**
   - POST `{{baseUrl}}/api/auth/login` with body above.
   - In **Tests** tab: `pm.environment.set("token", pm.response.json().data.token);`

3. **Auth for other requests**
   - In **Authorization** tab: Type **Bearer Token**, Token = `{{token}}`

4. **Optional:** Import the collection: **File → Import** → choose `backend/project-tracker-api.postman_collection.json`. Then set env `baseUrl` and run **Login** to set `token`.
