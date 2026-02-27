# Postman – all APIs with fake data (copy-paste ready)

**Base URL:** `https://project-traker-backend.onrender.com`

Use these in Postman: set **Body → raw → JSON** and paste the JSON. For auth-required APIs, first run **Login** or **Sign up**, copy `data.token` from the response, then set **Authorization** → **Bearer Token** and paste the token.

---

## 1. Login
**POST** `https://project-traker-backend.onrender.com/api/auth/login`

```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03"
}
```

With ID card (optional):
```json
{
  "email": "admin@taker.com",
  "password": "Dhanush@03",
  "idCardNumber": "000-0000-001"
}
```

---

## 2. Sign up
**POST** `https://project-traker-backend.onrender.com/api/auth/signup`

```json
{
  "fullName": "Raju Kumar",
  "email": "raju.fake@example.com",
  "password": "Fake@1234",
  "confirmPassword": "Fake@1234",
  "role": "member",
  "position": "Developer",
  "idCardNumber": "2003"
}
```

Another (team leader):
```json
{
  "fullName": "Priya Sharma",
  "email": "priya.fake@example.com",
  "password": "Fake@5678",
  "confirmPassword": "Fake@5678",
  "role": "team_leader",
  "position": "Tester"
}
```

---

## 3. Login with role (demo)
**POST** `https://project-traker-backend.onrender.com/api/auth/login-with-role`

```json
{
  "role": "admin"
}
```

Try also: `"role": "manager"` or `"role": "member"` or `"role": "team_leader"`

---

## 4. Forgot password
**POST** `https://project-traker-backend.onrender.com/api/auth/forgot-password`

```json
{
  "email": "raju.fake@example.com"
}
```

---

## 5. Verify captcha (use answer from forgot-password response)
**POST** `https://project-traker-backend.onrender.com/api/auth/verify-captcha`

```json
{
  "email": "raju.fake@example.com",
  "captchaAnswer": "8"
}
```

---

## 6. Reset password  
**POST** `https://project-traker-backend.onrender.com/api/auth/reset-password`  
**Header:** `Authorization: Bearer <reset_token_from_verify_captcha>`

```json
{
  "newPassword": "NewFake@123",
  "confirmPassword": "NewFake@123"
}
```

---

## 7. Get all projects (need token)
**GET** `https://project-traker-backend.onrender.com/api/projects`  
**Header:** `Authorization: Bearer <token>`

No body.

---

## 8. Get all tasks (need token)
**GET** `https://project-traker-backend.onrender.com/api/tasks`  
**Header:** `Authorization: Bearer <token>`

Optional: `https://project-traker-backend.onrender.com/api/tasks?status=ongoing`

---

## 9. Create task (need token)
**POST** `https://project-traker-backend.onrender.com/api/tasks`  
**Header:** `Authorization: Bearer <token>`

```json
{
  "title": "Review fake API design",
  "status": "need_to_start",
  "dueDate": "2025-04-15",
  "assignedToId": 3
}
```

Minimal:
```json
{
  "title": "Fake task title"
}
```

---

## 10. Update task status (need token)
**PATCH** `https://project-traker-backend.onrender.com/api/tasks/1/status`  
**Header:** `Authorization: Bearer <token>`  
(Replace `1` with real task id.)

```json
{
  "status": "ongoing"
}
```

---

## 11. Delete task (need token)
**DELETE** `https://project-traker-backend.onrender.com/api/tasks/1`  
**Header:** `Authorization: Bearer <token>`  
(Replace `1` with real task id.)

No body.

---

## 12. Assign task (need token)
**POST** `https://project-traker-backend.onrender.com/api/tasks/assign`  
**Header:** `Authorization: Bearer <token>`

```json
{
  "userId": 3,
  "taskTitle": "Fake assign task",
  "dueDate": "2025-04-20",
  "projectId": 1
}
```

---

## 13. Get all users (need token)
**GET** `https://project-traker-backend.onrender.com/api/users`  
**Header:** `Authorization: Bearer <token>`

No body.

---

## 14. Create user – Admin/Manager only (need token)
**POST** `https://project-traker-backend.onrender.com/api/users`  
**Header:** `Authorization: Bearer <token>`

```json
{
  "fullName": "Fake New User",
  "email": "newuser.fake@example.com",
  "password": "Welcome@1",
  "role": "member",
  "position": "Developer",
  "title": "Junior Dev",
  "temporary": false
}
```

---

## 15. Assign role – Admin/Manager only (need token)
**PATCH** `https://project-traker-backend.onrender.com/api/users/3/role`  
**Header:** `Authorization: Bearer <token>`  
(Replace `3` with real user id.)

```json
{
  "role": "team_leader",
  "position": "Tester"
}
```

---

## 16. Team leader – projects (need token)
**GET** `https://project-traker-backend.onrender.com/api/users/team-leader/projects`  
**Header:** `Authorization: Bearer <token>`

---

## 17. Team leader – team members (need token)
**GET** `https://project-traker-backend.onrender.com/api/users/team-leader/team-members`  
**Header:** `Authorization: Bearer <token>`

---

## 18. Team leader – team manager (need token)
**GET** `https://project-traker-backend.onrender.com/api/users/team-leader/team-manager`  
**Header:** `Authorization: Bearer <token>`

---

## 19. Member – projects (need token)
**GET** `https://project-traker-backend.onrender.com/api/users/member/projects`  
**Header:** `Authorization: Bearer <token>`

---

## 20. Member – contacts (need token)
**GET** `https://project-traker-backend.onrender.com/api/users/member/contacts`  
**Header:** `Authorization: Bearer <token>`

---

## 21. Health check (no auth)
**GET** `https://project-traker-backend.onrender.com/actuator/health`

No body, no headers.

---

## Quick order to test

1. **Login** or **Sign up** → copy `data.token`.
2. Set **Authorization: Bearer** `<paste token>` for all other requests.
3. **Get projects** → **Get tasks** → **Create task** → **Get users** etc.

All IDs (`1`, `3`) are fake; replace with real ids from your **Get tasks** / **Get users** responses if needed.
