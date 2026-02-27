# Check: Is the frontend passing data to the database?

The flow is: **Frontend (Flutter)** → **Backend (localhost:8080)** → **Database (PostgreSQL)**.

---

## 1. Confirm frontend talks to your backend

- The app uses **`http://localhost:8080`** only (see `frontend/lib/core/network/api_config.dart`).
- **Backend must be running** before you use the app: `cd backend; .\run-backend.ps1`.
- If the backend is not running, the app will get connection errors and no data will reach the database.

---

## 2. Actions that write to the database

| What you do in the app | Frontend calls | Backend writes to DB |
|------------------------|----------------|----------------------|
| **Sign up** (new account) | POST `/api/auth/signup` | New row in `users` |
| **Login** | POST `/api/auth/login` | Reads from `users` (no new row) |
| **Create task** (e.g. Admin/Manager) | POST `/api/tasks` | New row in `tasks` |
| **Update task status** | PATCH `/api/tasks/{id}/status` | Update in `tasks` |
| **Delete task** | DELETE `/api/tasks/{id}` | Delete from `tasks` |
| **Assign task** | POST `/api/tasks/assign` | New/update in `tasks` |
| **Create user** (Admin/Manager) | POST `/api/users` | New row in `users` |
| **Assign role** | PATCH `/api/users/{id}/role` | Update in `users` |

So signup, create task, create user, assign role, update task, delete task, and assign task all send data from the frontend to the backend, and the backend persists it to the database.

---

## 3. Quick test: frontend → database

1. **Start backend** (so DB is connected):
   ```powershell
   cd D:\Project_traker\backend
   .\run-backend.ps1
   ```
2. **Start frontend** (e.g. `flutter run -d chrome`).
3. **Sign up** in the app with a new email (e.g. `test@example.com`, password, role Member, position Developer).
4. **Backend console:** With `show-sql: true` in `application.yml`, you should see an **INSERT** into `users` when signup succeeds.
5. **pgAdmin:** Open **project-Tracker** → **Schemas** → **public** → **Tables** → **users**. Right‑click **users** → **Refresh**, then **View/Edit Data** → **All Rows**. You should see the new user (e.g. `test@example.com`).

If the new row appears in pgAdmin, the frontend **is** passing data to the database (via the backend).

---

## 4. If data does not appear in the database

- **Backend not running** → Start it; the app only talks to `http://localhost:8080`.
- **Wrong database in pgAdmin** → Open the same DB the backend uses (see backend startup log: `[DB] Connected to: ... project-Tracker`). Right‑click table → **Refresh** after each test.
- **Errors in the app** → Check the browser console (F12) or the backend console for 4xx/5xx or exceptions.
- **Backend returns 200 but no row** → Check backend console for SQL (with `show-sql: true`); you should see INSERT/UPDATE. If you see errors there, the write to the DB failed.

---

## Summary

| Check | How |
|-------|-----|
| Frontend URL | Always `http://localhost:8080` (api_config.dart). |
| Backend up | Run `.\run-backend.ps1`; health: http://localhost:8080/actuator/health |
| DB connected | Health shows `"db":{"status":"UP"}` or run `.\scripts\check-db-connection.ps1` |
| Data reaching DB | Do **Sign up** in app → see new row in **users** in pgAdmin after refresh. |
