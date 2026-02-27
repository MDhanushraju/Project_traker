# Postman – APIs with fake data

**Base URL:** `http://localhost:8080`  
**Content-Type:** `application/json` for all POST/PATCH bodies.

---

## 1. Get a token (use in later requests)

### Login (email + password)
- **Method:** POST  
- **URL:** `http://localhost:8080/api/auth/login`  
- **Headers:** `Content-Type: application/json`  
- **Body (raw JSON):**
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03"
}
```
- **With ID card (optional):**
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03",
  "idCardNumber": "000-0000-001"
}
```
- **Example success response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "role": "admin",
    "email": "admin@taker.com",
    "fullName": "Admin User"
  }
}
```
**→ Copy `data.token` and set it as Header:** `Authorization: Bearer <token>` for the rest of the requests.

---

### Login by role (get token for admin / manager / member / team_leader)
- **Method:** POST  
- **URL:** `http://localhost:8080/api/auth/login-with-role`  
- **Body (raw JSON):**
```json
{ "role": "admin" }
```
Other values: `"manager"`, `"member"`, `"team_leader"`.

---

### Sign up (fake new user)
- **Method:** POST  
- **URL:** `http://localhost:8080/api/auth/signup`  
- **Body (raw JSON):**
```json
{
  "fullName": "Jane Doe",
  "email": "jane.doe@example.com",
  "password": "Password1!",
  "confirmPassword": "Password1!",
  "role": "member",
  "idCardNumber": "000-0000-099",
  "position": "Developer"
}
```
Roles: `admin`, `manager`, `member`, `team_leader`.  
For `member` / `team_leader`, you can set `"position": "Developer"` or `"Tester"`, `"Designer"`, `"Analyst"`.

---

### Forgot password
- **Method:** POST  
- **URL:** `http://localhost:8080/api/auth/forgot-password`  
- **Body:**
```json
{ "email": "admin@taker.com" }
```
Response includes `captchaQuestion` (e.g. "What is 3 + 5?"). Use answer in verify-captcha.

---

### Verify captcha (after forgot-password)
- **Method:** POST  
- **URL:** `http://localhost:8080/api/auth/verify-captcha`  
- **Body:**
```json
{
  "email": "admin@taker.com",
  "captchaAnswer": "8"
}
```
Use the correct sum from the captcha question. Response has `resetToken`. Use it in reset-password.

---

### Reset password
- **Method:** POST  
- **URL:** `http://localhost:8080/api/auth/reset-password`  
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <reset_token_from_verify_captcha>`  
- **Body:**
```json
{
  "newPassword": "NewPass1!",
  "confirmPassword": "NewPass1!"
}
```

---

## 2. Projects (need Authorization header)

### Get all projects
- **Method:** GET  
- **URL:** `http://localhost:8080/api/projects`  
- **Headers:** `Authorization: Bearer <token>`  
- **Example response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OK",
  "data": [
    { "id": 1, "name": "Website Redesign", "status": "Active", "progress": 65 },
    { "id": 2, "name": "Mobile App", "status": "Planning", "progress": 10 }
  ]
}
```

---

## 3. Tasks (need Authorization header)

### Get all tasks
- **Method:** GET  
- **URL:** `http://localhost:8080/api/tasks`  
- **Headers:** `Authorization: Bearer <token>`  

**Filter by user:**
- **URL:** `http://localhost:8080/api/tasks?userId=2`

**Example response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OK",
  "data": [
    { "id": 1, "title": "Setup dev environment", "status": "ongoing", "dueDate": "2025-03-15" },
    { "id": 2, "title": "Review API design", "status": "need_to_start", "dueDate": "2025-03-20" }
  ]
}
```

---

### Create task
- **Method:** POST  
- **URL:** `http://localhost:8080/api/tasks`  
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`  
- **Body:**
```json
{
  "title": "Write unit tests",
  "status": "need_to_start",
  "dueDate": "2025-04-01"
}
```
`status` can be: `need_to_start`, `ongoing`, `completed`. `dueDate` format: `yyyy-MM-dd`.

---

### Update task status
- **Method:** PATCH  
- **URL:** `http://localhost:8080/api/tasks/1/status`  
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`  
- **Body:**
```json
{ "status": "ongoing" }
```
Or `"completed"`, `"need_to_start"`.

---

### Delete task
- **Method:** DELETE  
- **URL:** `http://localhost:8080/api/tasks/1`  
- **Headers:** `Authorization: Bearer <token>`  
- **Response:** 204 No Content (no body).

---

### Assign task
- **Method:** POST  
- **URL:** `http://localhost:8080/api/tasks/assign`  
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`  
- **Body:**
```json
{
  "userId": 3,
  "taskTitle": "Review design doc",
  "dueDate": "2025-03-25",
  "projectId": 1
}
```
`dueDate` and `projectId` are optional.

---

## 4. Users (need Authorization header; admin/manager for create and assign role)

### Get all users
- **Method:** GET  
- **URL:** `http://localhost:8080/api/users`  
- **Headers:** `Authorization: Bearer <token>`  
- **Example response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "OK",
  "data": [
    { "id": 1, "name": "Admin User", "title": "", "role": "admin", "position": null, "temporary": false },
    { "id": 2, "name": "Sarah Jenkins", "title": "Project Lead", "role": "manager", "position": null, "temporary": false },
    { "id": 3, "name": "Marcus Thorne", "title": "", "role": "team_leader", "position": "Developer", "temporary": false }
  ]
}
```

---

### Create user
- **Method:** POST  
- **URL:** `http://localhost:8080/api/users`  
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`  
- **Body:**
```json
{
  "fullName": "Alex Smith",
  "email": "alex.smith@example.com",
  "password": "Welcome@1",
  "role": "member",
  "position": "Tester",
  "title": "QA Engineer",
  "temporary": false
}
```
`password` optional (default used if blank). Roles: `admin`, `manager`, `team_leader`, `member`.  
Position for team_leader/member: `Developer`, `Tester`, `Designer`, `Analyst`.

---

### Assign / change role
- **Method:** PATCH  
- **URL:** `http://localhost:8080/api/users/3/role`  
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`  
- **Body:**
```json
{
  "role": "team_leader",
  "position": "Developer"
}
```
Use real user `id` from GET /api/users. `position` optional for team_leader/member.

---

### Team leader – my projects
- **Method:** GET  
- **URL:** `http://localhost:8080/api/users/team-leader/projects`  
- **Headers:** `Authorization: Bearer <token>` (must be a team_leader token)  
- **Example response:** `{ "data": [ "Website Redesign", "Mobile App" ] }`

---

### Team leader – team members by project
- **Method:** GET  
- **URL:** `http://localhost:8080/api/users/team-leader/team-members`  
- **Headers:** `Authorization: Bearer <token>`  
- **Example response:**
```json
{
  "data": {
    "Website Redesign": [
      { "id": 4, "name": "John Dev", "title": "Developer", "position": "Developer" }
    ]
  }
}
```

---

### Team leader – my manager
- **Method:** GET  
- **URL:** `http://localhost:8080/api/users/team-leader/team-manager`  
- **Headers:** `Authorization: Bearer <token>`  
- **Example response:** `{ "data": { "name": "Sarah Jenkins", "title": "Manager" } }`

---

### Member – my projects
- **Method:** GET  
- **URL:** `http://localhost:8080/api/users/member/projects`  
- **Headers:** `Authorization: Bearer <token>` (must be a member token)

---

### Member – contacts
- **Method:** GET  
- **URL:** `http://localhost:8080/api/users/member/contacts`  
- **Headers:** `Authorization: Bearer <token>`  
- **Example response:**
```json
{
  "data": [
    { "name": "Sarah Jenkins", "title": "Manager", "type": "Manager" },
    { "name": "Marcus Thorne", "title": "", "type": "Team Leader" }
  ]
}
```

---

## Quick reference – fake data (DataLoader seeds these)

| Use case     | Email             | Password    | Role        |
|-------------|-------------------|-------------|-------------|
| Admin       | admin@taker.com   | Dhanush@03  | admin       |
| Manager     | manager@taker.com  | Password@1  | manager     |
| Team leader | leader@taker.com   | Password@1  | team_leader |
| Member      | member@taker.com  | Password@1  | member      |

Use these in **Login** or **Login by role**. Task and user IDs: use values from GET /api/tasks and GET /api/users (e.g. 1, 2, 3).
