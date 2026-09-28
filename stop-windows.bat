@echo off
title OpenBot Stopper
echo ===============================================
echo            Stopping OpenBot Stack
echo ===============================================
echo.

:: Switch to OpenBot directory
if exist "%~dp0docker-compose.yml" (
    cd /d "%~dp0"
) else if exist "A:\OpenBot\docker-compose.yml" (
    cd /d "A:\OpenBot"
)

echo [1/2] Stopping Docker containers...
docker compose stop

echo [2/2] Stopping background bun/server processes on ports 3001 and 3010...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3001 " ^| findstr LISTENING') do taskkill /f /t /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3010 " ^| findstr LISTENING') do taskkill /f /t /pid %%a >nul 2>&1

echo.
echo ===============================================
echo   OpenBot has been stopped.
echo ===============================================
echo.
