# Step-by-Step: Deploy Backend to Render

Follow these steps in order to deploy the Project Tracker backend to Render using Docker.

---

## Step 1: Ensure `gradle-wrapper.jar` is in your repo

Render needs the Gradle wrapper JAR to build inside Docker.

**Check if it exists:**
```powershell
# From project root
dir D:\Project_traker\backend\gradle\wrapper\gradle-wrapper.jar
```

**If it exists:** Commit it if not already tracked:
```powershell
cd D:\Project_traker\backend
git add gradle/wrapper/gradle-wrapper.jar
git status
# If it shows as new/modified:
git commit -m "Add gradle-wrapper.jar for Docker build"
git push origin main
```

**If it does NOT exist:** Generate it, then commit:
```powershell
cd D:\Project_traker\backend
gradle wrapper
git add gradle/wrapper/gradle-wrapper.jar
git commit -m "Add gradle-wrapper.jar for Docker build"
git push origin main
```

---

## Step 2: Push your code to GitHub

Ensure your repo (including the `backend/` folder and `Dockerfile`) is on GitHub:

```powershell
cd D:\Project_traker
git add .
git commit -m "Add Dockerfile and Render deployment"
git push origin main
```

---

## Step 3: Create a Render account and connect GitHub

1. Go to **https://render.com** and sign up (or log in).
2. Click **Dashboard**.
3. Click **Connect account** under GitHub and authorize Render to access your repo.
4. Render will list your GitHub repos.

---

## Step 4: Create a PostgreSQL database

1. In Render Dashboard, click **New +** → **PostgreSQL**.
2. Configure:
   - **Name:** `project-tracker-db` (or any name)
   - **Region:** Choose closest to you (e.g. Oregon)
   - **PostgreSQL Version:** 16
   - **Plan:** Free (or paid)
3. Click **Create Database**.
4. Wait until status is **Available**.
5. Open the database and copy the **Internal Database URL** (you’ll use this next).  
   Example: `postgresql://user:password@host/dbname?sslmode=require`

---

## Step 5: Create a Web Service (Docker)

1. In Render Dashboard, click **New +** → **Web Service**.
2. Connect your GitHub repo:
   - **Connect repository:** Select the repo that has `D:\Project_traker` (the one with the `backend` folder).
   - Click **Connect**.

3. Configure the Web Service:

   | Field | Value |
   |-------|-------|
   | **Name** | `project-tracker-backend` (or any name) |
   | **Region** | Same as PostgreSQL (e.g. Oregon) |
   | **Root Directory** | `backend` |
   | **Runtime** | Docker |
   | **Plan** | Free (or paid) |

4. Environment variables — click **Add Environment Variable** and add:

   | Key | Value |
   |-----|-------|
   | `SPRING_DATASOURCE_URL` | Paste the Internal Database URL from Step 4 |
   | `SPRING_DATASOURCE_USERNAME` | Username from that URL (or leave if URL includes it) |
   | `SPRING_DATASOURCE_PASSWORD` | Password from that URL |

   If the Internal URL is  
   `postgresql://user123:pass456@dpg-xxx/dbname?sslmode=require`  
   you can set:
   - `SPRING_DATASOURCE_URL` = `jdbc:postgresql://dpg-xxx/dbname?sslmode=require`  
     (replace host with the host from the URL, e.g. `jdbc:postgresql://dpg-xxx.oregon-postgres.render.com/dbname?sslmode=require`)
   - `SPRING_DATASOURCE_USERNAME` = `user123`
   - `SPRING_DATASOURCE_PASSWORD` = `pass456`

5. Click **Create Web Service**.

---

## Step 6: Deploy and wait

1. Render will build the Docker image and start the service.
2. First deploy may take 5–10 minutes (Gradle build, dependencies).
3. Watch the **Logs** tab for progress.
4. When status is **Live**, deployment is done.

---

## Step 7: Verify

1. On the Web Service page, copy the **URL** (e.g. `https://project-tracker-backend.onrender.com`).
2. Test:
   - `https://your-service.onrender.com` → Should redirect to Swagger
   - `https://your-service.onrender.com/swagger-ui.html` → Swagger UI
   - `https://your-service.onrender.com/actuator/health` → Health JSON

---

## Step 8: Update your Flutter app (API base URL)

Point your Flutter app at the Render backend:

1. Find where the API base URL is set (e.g. `http://localhost:8080`).
2. Change it to your Render URL, e.g. `https://project-tracker-backend.onrender.com`.
3. Rebuild and run the Flutter app.

---

## Troubleshooting

| Issue | What to do |
|-------|------------|
| Build fails with "gradle-wrapper.jar not found" | Add and commit `gradle/wrapper/gradle-wrapper.jar` (Step 1). |
| Build fails with "COPY failed" | Ensure Root Directory is set to `backend`. |
| App starts then crashes | Check Logs; often DB URL, username, or password wrong. Use the Internal Database URL from the PostgreSQL service. |
| 503 or timeout | Free tier sleeps after inactivity; first request can be slow. |

---

## Summary checklist

- [ ] `gradle-wrapper.jar` is in repo
- [ ] Code pushed to GitHub
- [ ] Render account connected to GitHub
- [ ] PostgreSQL database created
- [ ] Web Service created with Root Directory = `backend`, Runtime = Docker
- [ ] `SPRING_DATASOURCE_URL`, `USERNAME`, `PASSWORD` set
- [ ] Service is Live
- [ ] Flutter app uses Render URL instead of localhost
