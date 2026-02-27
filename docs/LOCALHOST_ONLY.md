# Localhost only — no Render

The app uses **only your system's local backend and database**. Render is not used.

**New setup?** → Follow ** [SETUP_PGADMIN_FROM_START.md](SETUP_PGADMIN_FROM_START.md)** to connect pgAdmin from start (PostgreSQL → pgAdmin → backend).

---

## 1. Backend (local)

- **Config:** `application.yml` → `jdbc:postgresql://localhost:5432/project-Tracker`. No `DATABASE_URL` when using local.
- **Profile:** Run with `--spring.profiles.active=local` and set `DATABASE_USERNAME` / `DATABASE_PASSWORD` in `backend/.env.local`.
- **Start:**
  ```powershell
  cd backend
  .\run-backend.ps1
  ```
- **API:** http://localhost:8080  
- **Health:** http://localhost:8080/actuator/health (should show `"db":{"status":"UP"}`)

---

## 2. Database (pgAdmin / local PostgreSQL)

- **Host:** localhost  
- **Port:** 5432  
- **Database:** project-Tracker  
- **User:** postgres (or value from `DATABASE_USERNAME` in `.env.local`)  
- Backend connects to this DB when `DATABASE_URL` is not set.

---

## 3. Frontend (local)

- **API URL:** Always `http://localhost:8080`. No dart-defines needed.
- **Start:**
  ```powershell
  cd frontend
  flutter run -d chrome
  ```
- Frontend talks only to the local backend.

---

## 4. Quick check (all working)

1. **Backend up:** Open http://localhost:8080/actuator/health → JSON with `"status":"UP"` and `"db":{"status":"UP"}`.
2. **Login:** In the app, log in with `admin@taker.com` / `Dhanush@03` → should succeed and redirect.
3. **API test (optional):** From project root run `.\scripts\test-all-apis.ps1 -BaseUrl "http://localhost:8080"` and use the same credentials in the script if needed.

If login returns 400/401, check that the backend is running and that the user exists in pgAdmin with the correct password (DataLoader sets admin password on startup).

---

## Data not updating in pgAdmin

1. **Same database:** When the backend starts, it logs: `[DB] Connected to: jdbc:postgresql://localhost:5432/project-Tracker`. In pgAdmin, open **exactly** that database (same name: `project-Tracker` or `project_tracker`). If the name in pgAdmin is different, change `spring.datasource.url` in `application.yml` to use that name, or create a database with the same name.
2. **Refresh:** In pgAdmin, right‑click the table → **Refresh** to see new rows after API calls or DataLoader.
3. **Profile:** Run the backend with profile `local` (`.\run-backend.ps1`) so it uses your local DB and `.env.local` credentials.
