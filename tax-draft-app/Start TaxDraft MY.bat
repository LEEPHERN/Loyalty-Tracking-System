@echo off
rem Start the app server (serves the frontend + proxies AI calls), then open it in the browser.
rem Frees port 8765 first in case an old instance is still running.
powershell -ExecutionPolicy Bypass -Command "Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }"
start "TaxDraft Server" /min powershell -ExecutionPolicy Bypass -File "%~dp0proxy.ps1"
timeout /t 2 /nobreak >NUL
start "" "http://localhost:8765/"
echo TaxDraft MY is running at http://localhost:8765/ — keep the minimized server window open while using the app.
