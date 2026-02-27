# Local server + pgAdmin (localhost only)

The app is configured to use **only localhost** — local backend and pgAdmin. Render is not used; the frontend always calls `http://localhost:8080`.

---

## Local server + pgAdmin (default)

### Backend
1. Install PostgreSQL and create database `project-Tracker` (or run `backend/scripts/create-db.ps1`).
2. In `backend/` create `.env.local` (see `backend/.env.local.example`):
   - `DATABASE_USERNAME=postgres`
   - `DATABASE_PASSWORD=your_pg_password`
   - **Do not set** `DATABASE_URL` when using local.
3. Run backend:
   ```powershell
   cd backend
   .\run-backend.ps1
   ```
   API: http://localhost:8080

### Frontend
- No change needed. Default is `http://localhost:8080`.
- Run: `flutter run` (or `flutter run -d chrome` / `-d windows`).

### pgAdmin
- Connect to `localhost:5432`, user `postgres`, database `project-Tracker`.
- Backend uses this DB when `DATABASE_URL` is not set and profile `local` is active.

---

## See also

- **Full local check:** `docs/LOCALHOST_ONLY.md`
