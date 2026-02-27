# Connectivity checklist: Frontend ↔ Backend ↔ Database

## 1. Frontend ↔ Backend — **Connected** ✓

If you see an HTTP response (e.g. 500, 401, 400) from `project-traker-backend.onrender.com`, the frontend **is** reaching the backend. A 500 means the server received the request but failed while processing it (we fixed signup to return 400 with a message instead of 500 after redeploy).

- **To verify:** Open `https://project-traker-backend.onrender.com/actuator/health` in the browser. You should see JSON (e.g. `{"status":"UP"}`). If the page loads, backend is up and reachable.

## 2. Backend ↔ Database (Render)

On **Render**, the backend uses the **DATABASE_URL** environment variable (Internal Database URL from your PostgreSQL service).

- **To verify:** In Render Dashboard → your **Web Service** → **Environment**, ensure **DATABASE_URL** is set (use the **Internal** URL from the PostgreSQL service, not the external one).
- **Do not set** `DATABASE_USERNAME`, `DATABASE_PASSWORD`, or `SPRING_DATASOURCE_*` — the URL contains the credentials.
- If the DB were disconnected, the app would usually fail at startup (HikariPool error) or when the first DB call runs. After the signup fix, any failure during signup should return **400** with a message like "Email already registered" or "Registration failed. Please try again." instead of 500.

## 3. After a 500 on signup

1. **Redeploy** the backend to Render so the latest signup error handling is live.
2. Check **Render → your service → Logs** for the exception stack trace. That will show the exact cause (e.g. DB constraint, missing table, null pointer).
3. Ensure **JWT_SECRET** is set in the Web Service environment on Render (required for token generation after signup).

## Summary

| Check              | How to verify |
|--------------------|----------------|
| Frontend → Backend | You get HTTP 4xx/5xx from the API (not "connection refused" or CORS block). |
| Backend → Database | Render env has **DATABASE_URL** (Internal). App starts without DB errors in logs. |
| Signup errors      | After redeploy, signup returns 400 with a clear message instead of 500. |
