# OpenBot PowerShell Stopper
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "           Stopping OpenBot Stack              " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Set-Location $PSScriptRoot

# 1. Stop Docker
Write-Host "`n[1/2] Stopping Docker containers..." -ForegroundColor Yellow
docker compose -f "$PSScriptRoot\docker-compose.yml" --project-directory "$PSScriptRoot" stop

# 2. Kill processes on ports 3001 and 3010
Write-Host "[2/2] Stopping processes on ports 3001 and 3010..." -ForegroundColor Yellow
foreach ($port in @(3001, 3010)) {
    $conns = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    foreach ($conn in $conns) {
        try {
            Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
        } catch {}
    }
}

Write-Host "`n===============================================" -ForegroundColor Green
Write-Host "  OpenBot has been stopped." -ForegroundColor Green
Write-Host "===============================================`n" -ForegroundColor Green
