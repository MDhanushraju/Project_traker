# Creates the project_tracker database in PostgreSQL (required before first bootRun).
# Usage: run from repo root or backend folder:
#   .\backend\scripts\create-db.ps1
#   # or: cd backend; .\scripts\create-db.ps1
#
# If postgres user has a password, set it first:
#   $env:PGPASSWORD = "your_password"

$dbName = "project_tracker"
$user = "postgres"

try {
    $result = psql -U $user -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$dbName'"
    if ($result -match "1") {
        Write-Host "Database '$dbName' already exists."
    } else {
        psql -U $user -d postgres -c "CREATE DATABASE $dbName;"
        Write-Host "Database '$dbName' created."
    }
} catch {
    Write-Host "Run CREATE DATABASE manually: psql -U postgres -c `"CREATE DATABASE $dbName;`""
    exit 1
}
