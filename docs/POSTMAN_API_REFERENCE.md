# Postman API reference

**Base URL (Render):** `https://project-traker-backend.onrender.com`  
**Base URL (local):** `http://localhost:8080`

For endpoints that need auth, add header: **Authorization:** `Bearer <token>` (use the `token` from login/signup response).

---

## 1. Auth (no token required)

### 1.1 Login
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/auth/login`
- **Body (JSON):**
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03"
}
```
- **Optional:** `"idCardNumber": "000-0000-001"` if you use ID card at login.

---

### 1.2 Sign up
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/auth/signup`
- **Body (JSON):**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "Password@1",
  "confirmPassword": "Password@1",
  "role": "member",
  "position": "Developer"
}
```
- **Optional:** `"idCardNumber": "000-0000-005"`
- **role:** `admin` | `manager` | `member` | `team_leader`
- **position:** For `team_leader` / `member`: `Developer` | `Tester` | `Designer` | `Analyst`

---

### 1.3 Login with role (demo – get token for first user with that role)
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/auth/login-with-role`
- **Body (JSON):**
```json
{
  "role": "admin"
}
```
- **role:** `admin` | `manager` | `team_leader` | `member`

---

### 1.4 Forgot password
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/auth/forgot-password`
- **Body (JSON):**
```json
{
  "email": "admin@taker.com"
}
```

---

### 1.5 Verify captcha (get reset token)
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/auth/verify-captcha`
- **Body (JSON):**
```json
{
  "email": "admin@taker.com",
  "captchaAnswer": "8"
}
```
- Use the captcha question/answer from forgot-password response.

---

### 1.6 Reset password
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/auth/reset-password`
- **Header:** `Authorization: Bearer <reset_token>` (token from verify-captcha)
- **Body (JSON):**
```json
{
  "newPassword": "NewPass@1",
  "confirmPassword": "NewPass@1"
}
```

---

## 2. Projects (JWT required)

### 2.1 Get all projects
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/projects`
- **Header:** `Authorization: Bearer <token>`

---

## 3. Tasks (JWT required)

### 3.1 Get tasks
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/tasks`
- **Header:** `Authorization: Bearer <token>`
- **Query (optional):** `?status=ongoing` (filter by status)

---

### 3.2 Create task
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/tasks`
- **Header:** `Authorization: Bearer <token>`
- **Body (JSON):**
```json
{
  "title": "Setup dev environment",
  "status": "need_to_start",
  "dueDate": "2025-03-15",
  "assignedToId": 3
}
```
- **status:** `need_to_start` | `ongoing` | `completed`
- **assignedToId:** optional; omit to assign to current user.

---

### 3.3 Update task status
- **Method:** `PATCH`
- **URL:** `{{baseUrl}}/api/tasks/{id}/status`
- **Header:** `Authorization: Bearer <token>`
- **Body (JSON):**
```json
{
  "status": "ongoing"
}
```
- **status:** `need_to_start` | `ongoing` | `completed`

---

### 3.4 Delete task
- **Method:** `DELETE`
- **URL:** `{{baseUrl}}/api/tasks/{id}`
- **Header:** `Authorization: Bearer <token>`

---

### 3.5 Assign task
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/tasks/assign`
- **Header:** `Authorization: Bearer <token>`
- **Body (JSON):**
```json
{
  "userId": 3,
  "taskTitle": "Review API design",
  "dueDate": "2025-03-20",
  "projectId": 1
}
```

---

## 4. Users (JWT required – Admin/Manager for create/assign)

### 4.1 Get all users
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/users`
- **Header:** `Authorization: Bearer <token>`

---

### 4.2 Create user (Admin/Manager)
- **Method:** `POST`
- **URL:** `{{baseUrl}}/api/users`
- **Header:** `Authorization: Bearer <token>`
- **Body (JSON):**
```json
{
  "fullName": "Jane Smith",
  "email": "jane@taker.com",
  "password": "Welcome@1",
  "role": "member",
  "position": "Developer",
  "title": "Senior Developer",
  "temporary": false
}
```

---

### 4.3 Assign role (Admin/Manager)
- **Method:** `PATCH`
- **URL:** `{{baseUrl}}/api/users/{id}/role`
- **Header:** `Authorization: Bearer <token>`
- **Body (JSON):**
```json
{
  "role": "team_leader",
  "position": "Tester"
}
```

---

### 4.4 Team leader – projects
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/users/team-leader/projects`
- **Header:** `Authorization: Bearer <token>`

---

### 4.5 Team leader – team members
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/users/team-leader/team-members`
- **Header:** `Authorization: Bearer <token>`

---

### 4.6 Team leader – team manager
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/users/team-leader/team-manager`
- **Header:** `Authorization: Bearer <token>`

---

### 4.7 Member – projects
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/users/member/projects`
- **Header:** `Authorization: Bearer <token>`

---

### 4.8 Member – contacts
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/users/member/contacts`
- **Header:** `Authorization: Bearer <token>`

---

## 5. Health (no auth)

### 5.1 Health check
- **Method:** `GET`
- **URL:** `{{baseUrl}}/api/actuator/health`

---

## Postman setup

1. Create an environment with variable **baseUrl** = `https://project-traker-backend.onrender.com` (or `http://localhost:8080` for local).
2. Call **Login** or **Sign up** and copy the `data.token` from the response.
3. For protected endpoints, set **Authorization** to **Bearer Token** and paste the token, or use a script to save `data.token` into an environment variable and use `{{token}}` in the header.

---

## Quick test for signup (400 check)

Use this in Postman to match the app and see the exact error message:

- **POST** `https://project-traker-backend.onrender.com/api/auth/signup`
- **Body (raw JSON):**
```json
{
  "fullName": "Test User",
  "email": "testuser@example.com",
  "password": "Test@1234",
  "confirmPassword": "Test@1234",
  "role": "member",
  "position": "Developer"
}
```

If you get **400**, the response body will have `message` and optionally `data` with field errors (e.g. "Email already registered", "Validation failed", etc.).
