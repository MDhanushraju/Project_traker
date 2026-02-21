# Swagger API Documentation

## Access Swagger UI

1. **Start the backend** (port 8080 by default)
2. Open in browser: **http://localhost:8080/swagger-ui.html**

## How to Test APIs

### 1. Get a token (no auth needed)
- Go to **Auth** → **POST /api/auth/login**
- Click **Try it out**
- Use example body (or edit):
  ```json
  {
    "email": "admin@taker.com",
    "password": "Admin@123"
  }
  ```
- Click **Execute**
- Copy the `token` from the response `data` object

### 2. Authorize
- Click the **Authorize** button (top right)
- Enter: `Bearer <paste_your_token_here>`
- Click **Authorize** then **Close**

### 3. Test other endpoints
- All **Users**, **Tasks**, **Projects** endpoints now use your token
- Each endpoint has example request bodies – click **Try it out** and use/edit them

## Test Credentials (DataLoader seeds)

| Role        | Email              | Password   |
|-------------|--------------------|-----------|
| Admin       | admin@taker.com    | Admin@123 |
| Manager     | manager@taker.com  | Password@1 |
| Team Leader | leader@taker.com   | Password@1 |
| Team Member | member@taker.com   | Password@1 |

## API Groups

- **Auth** – Login, signup, forgot/reset password (no token)
- **Users** – User CRUD, assign role, role-specific data (Admin/Manager token)
- **Tasks** – Create, update status, delete, assign tasks
- **Projects** – List projects

## OpenAPI spec (JSON)
Raw spec: http://localhost:8080/v3/api-docs
