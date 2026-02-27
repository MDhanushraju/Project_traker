# Connect pgAdmin from start

Follow these steps in order so the backend and pgAdmin use the **same** database.

---

## Step 1: PostgreSQL installed and running

- Install **PostgreSQL** if you don’t have it (e.g. from https://www.postgresql.org/download/windows/).
- During setup, set and remember the **postgres** user password (e.g. `Dhanush@03`).
- Ensure the PostgreSQL service is **running** (default port **5432**).

---

## Step 2: pgAdmin – add server and create database

1. Open **pgAdmin 4**.
2. **Add server** (or use existing “Local PostgreSQL”):
   - Right‑click **Servers** → **Register** → **Server**.
   - **General** tab: Name = `Local PostgreSQL` (or any name).
   - **Connection** tab:
     - Host: `localhost`
     - Port: `5432`
     - Username: `postgres`
     - Password: *(the password you set for postgres)*
   - Save (store password if you want pgAdmin to remember it).
3. **Create the database** the backend will use:
   - Expand **Servers** → your server → **Databases**.
   - Right‑click **Databases** → **Create** → **Database**.
   - **Database** name: **`project-Tracker`** (must match `application.yml`).
   - Owner: `postgres`.
   - Click **Save**.

You now have a database **project-Tracker** that pgAdmin and the backend will both use.

---

## Step 3: Backend – same user and password

1. In the project, go to the **backend** folder:
   ```
   D:\Project_traker\backend
   ```
2. Create **`.env.local`** (copy from `.env.local.example` if it exists), with the **same** user and password as in pgAdmin:
   ```env
   DATABASE_USERNAME=postgres
   DATABASE_PASSWORD=Dhanush@03
   ```
   *(Use your actual postgres password if different.)*

3. Do **not** set `DATABASE_URL` in `.env.local` when using this local setup.

---

## Step 4: Start the backend (connects to pgAdmin’s DB)

1. In a terminal:
   ```powershell
   cd D:\Project_traker\backend
   .\run-backend.ps1
   ```
2. Wait until you see something like:
   - `[DB] Connected to: jdbc:postgresql://localhost:5432/project-Tracker ...`
   - `Admin user updated: admin@taker.com / Dhanush@03` (or “Test user” if first run).
3. That means the backend is connected to the **same** database you see in pgAdmin.

---

## Step 5: Confirm in pgAdmin

1. In pgAdmin: **Servers** → your server → **Databases** → **project-Tracker**.
2. Expand **project-Tracker** → **Schemas** → **public** → **Tables**.
3. You should see tables (e.g. **users**, **projects**, **tasks**) created by the backend on first run.
4. Right‑click a table → **View/Edit Data** → **All Rows** to see data (e.g. admin user).
5. After API or app changes, right‑click the table → **Refresh** to see updates.

---

## Summary

| Where        | What to use                          |
|-------------|--------------------------------------|
| pgAdmin     | Server: localhost:5432, user postgres, DB **project-Tracker** |
| backend     | `.env.local`: same user/password; no DATABASE_URL |
| application.yml | Default URL: `jdbc:postgresql://localhost:5432/project-Tracker` |

If data doesn’t appear in pgAdmin, check that you’re looking at **project-Tracker** (same name as in the backend log) and that you’ve **refreshed** the table.
