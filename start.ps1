# OpenBot PowerShell Launcher
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "           Starting OpenBot Stack              " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Set-Location $PSScriptRoot

# 1. Docker
Write-Host "`n[1/4] Ensuring Docker services are up..." -ForegroundColor Yellow
docker compose -f "$PSScriptRoot\docker-compose.yml" --project-directory "$PSScriptRoot" up -d postgres supervisor agent-computer agent-bot agent-langgraph
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker failed to start. Make sure Docker Desktop is running." -ForegroundColor Red
    exit $LASTEXITCODE
}

# 2. Migrations & Config
Write-Host "[2/4] Generating config and running DB migrations..." -ForegroundColor Yellow
bun run generate:app-config
bun run --filter server db:migrate

# 3. Server
Write-Host "[3/4] Starting OpenBot Server on port 3001..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\server'; `$env:PORT='3001'; `$env:COMPUTER_SUPERVISOR_URL='http://localhost:4500'; `$env:SUPERVISOR_TOKEN='openbot-dev-supervisor-token'; `$env:COMPUTER_TOKEN='openbot-dev-computer-token'; `$env:WORKER_SHARED_SECRET='openbot-dev-worker-secret'; `$env:MANAGED_AGENT_AG_UI_URL='http://localhost:4201/ag-ui'; bun --env-file=../.env src/production-entry.ts"

# 4. Frontend
Write-Host "[4/4] Starting OpenBot Frontend on port 3010..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\app'; bun run dev --port 3010 --strictPort"

Write-Host "`n===============================================" -ForegroundColor Green
Write-Host "  OpenBot is running!" -ForegroundColor Green
Write-Host "  Web UI: http://localhost:3010" -ForegroundColor Green
Write-Host "===============================================`n" -ForegroundColor Green
