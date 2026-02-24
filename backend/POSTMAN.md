# Postman – Taker Auth API

**Run backend:** `.\gradlew.bat bootRun` or `.\run-backend.ps1`  
**Base URL:** `http://localhost:8080`

---

## 1. Sign Up

**POST** `/api/auth/signup`

```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "idCardNumber": "000-0000-100",
  "password": "John@123",
  "confirmPassword": "John@123",
  "role": "member"
}
```

`role`: `admin` | `manager` | `member`  
`idCardNumber`: optional

---

## 2. Login

**POST** `/api/auth/login`

```json
{
  "idCardNumber": "000-0000-001",
  "email": "admin@taker.com",
  "password": "Admin@123"
}
```

Response includes `token` and `role`. Use `token` in `Authorization: Bearer <token>` for protected APIs.

---

## 3. Forgot Password

**POST** `/api/auth/forgot-password`

```json
{
  "email": "admin@taker.com"
}
```

Returns `captchaQuestion` (e.g. "What is 7 + 5?"). User must solve and send answer in verify step.

---

## 4. Verify Captcha

**POST** `/api/auth/verify-captcha`

```json
{
  "email": "admin@taker.com",
  "captchaAnswer": "12"
}
```

Returns `resetToken`. Use this in the next step.

---

## 5. Reset Password

**POST** `/api/auth/reset-password`  
**Header:** `Authorization: Bearer <resetToken>`

```json
{
  "newPassword": "NewPass@123",
  "confirmPassword": "NewPass@123"
}
```

Password rules: at least 8 chars, one digit, one special character.

---

## Pre-seeded Test Users

| Email             | ID Card     | Password   | Role   |
|-------------------|-------------|------------|--------|
| admin@taker.com   | 000-0000-001| Admin@123  | admin  |
| member@taker.com  | 000-0000-003| Member@123 | member |
