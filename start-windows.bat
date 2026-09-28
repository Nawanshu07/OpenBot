@echo off
title OpenBot Launcher
echo ===============================================
echo            Starting OpenBot Stack
echo ===============================================
echo.

:: Switch to OpenBot directory
if exist "%~dp0docker-compose.yml" (
    cd /d "%~dp0"
) else if exist "A:\OpenBot\docker-compose.yml" (
    cd /d "A:\OpenBot"
) else (
    echo [ERROR] Could not find OpenBot directory with docker-compose.yml!
    pause
    exit /b 1
)

echo OpenBot Directory: %CD%
echo.

echo [1/4] Starting Docker services...
docker compose up -d postgres supervisor agent-computer agent-bot agent-langgraph
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Docker failed to start.
    echo 1. Make sure Docker Desktop is running!
    echo 2. Verified OpenBot path: %CD%
    pause
    exit /b %ERRORLEVEL%
)

echo [2/4] Applying database migrations ^& generating app config...
call bun run generate:app-config
call bun run --filter server db:migrate

echo [3/5] Starting OpenBot Server (port 3001)...
start "OpenBot Server" cmd /k "cd /d "%CD%\server" && set PORT=3001 && set COMPUTER_SUPERVISOR_URL=http://localhost:4500 && set SUPERVISOR_TOKEN=openbot-dev-supervisor-token && set COMPUTER_TOKEN=openbot-dev-computer-token && set WORKER_SHARED_SECRET=openbot-dev-worker-secret && set MANAGED_AGENT_AG_UI_URL=http://localhost:4201/ag-ui && bun --env-file=../.env src/production-entry.ts"

echo [4/5] Starting OpenBot Routine Worker (scheduler)...
start "OpenBot Worker" cmd /k "cd /d "%CD%" && bun --env-file=.env worker/src/index.ts"

echo [5/5] Starting OpenBot Frontend (port 3010)...
start "OpenBot App" cmd /k "cd /d "%CD%\app" && bun run dev --port 3010 --strictPort"

echo.
echo ===============================================
echo   OpenBot is starting up!
echo   Open your browser at: http://localhost:3010
echo ===============================================
echo.
