# How to Run the Backend Docker Image

This guide covers building and running the Project Tracker backend in Docker.

---

## Prerequisites

- **Docker** and **Docker Compose** installed ([Get Docker](https://docs.docker.com/get-docker/))
- From the **backend** directory: `D:\Project_traker\backend`

---

## Option 1: Backend + PostgreSQL (recommended)

Runs the backend and a PostgreSQL database in one go.

```powershell
cd D:\Project_traker\backend
docker compose up -d
```

- **Backend API:** http://localhost:8080  
- **Swagger UI:** http://localhost:8080/swagger-ui.html  
- **Health:** http://localhost:8080/actuator/health  

**Stop and remove containers:**
```powershell
docker compose down
```

**View logs:**
```powershell
docker compose logs -f backend
docker compose logs -f postgres
```

---

## Option 2: Build and run the backend image only

Use this when PostgreSQL is already running (on the host or elsewhere).

**1. Build the image:**
```powershell
cd D:\Project_traker\backend
docker build -t project-tracker-backend .
```

**2. Run the container:**

If PostgreSQL is on your **host** (e.g. Windows) at `localhost:5432`:
```powershell
docker run -d -p 8080:8080 `
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/project_tracker `
  -e SPRING_DATASOURCE_USERNAME=postgres `
  -e SPRING_DATASOURCE_PASSWORD=Dhanush@03 `
  --name project-tracker-backend `
  project-tracker-backend
```

If PostgreSQL is on **another host** (replace `YOUR_DB_HOST` and password if needed):
```powershell
docker run -d -p 8080:8080 `
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://YOUR_DB_HOST:5432/project_tracker `
  -e SPRING_DATASOURCE_USERNAME=postgres `
  -e SPRING_DATASOURCE_PASSWORD=YOUR_PASSWORD `
  --name project-tracker-backend `
  project-tracker-backend
```

**3. Stop and remove the container:**
```powershell
docker stop project-tracker-backend
docker rm project-tracker-backend
```

---

## Option 3: Run with custom port

To expose the backend on a different host port (e.g. 9090):

**Docker Compose:** edit `docker-compose.yml` and change `ports` to `"9090:8080"`, then:
```powershell
docker compose up -d
```

**Docker run:**
```powershell
docker run -d -p 9090:8080 `
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/project_tracker `
  -e SPRING_DATASOURCE_USERNAME=postgres `
  -e SPRING_DATASOURCE_PASSWORD=Dhanush@03 `
  --name project-tracker-backend `
  project-tracker-backend
```
Then open http://localhost:9090

---

## Useful commands

| Task | Command |
|------|---------|
| List running containers | `docker ps` |
| Backend logs | `docker logs -f project-tracker-backend` or `docker compose logs -f backend` |
| Restart backend | `docker compose restart backend` |
| Rebuild after code changes | `docker compose up -d --build` |
| Remove containers + volumes | `docker compose down -v` |

---

## Troubleshooting

- **Connection refused to database:** Ensure PostgreSQL is running and the host/port in `SPRING_DATASOURCE_URL` is correct. With `docker compose`, use the service name `postgres`; when the DB is on the host, use `host.docker.internal` (Windows/Mac).
- **Port 8080 already in use:** Stop the other process or use a different host port (e.g. `-p 9090:8080`).
- **Image build fails:** Run `docker build --no-cache -t project-tracker-backend .` and check that `gradle/wrapper` (including `gradle-wrapper.jar`) is present in the backend folder.
