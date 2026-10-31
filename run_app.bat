@echo off
title TRAVEL_APP — Khoi Dong Ung Dung
cd /d "%~dp0\mobile_flutter"

echo ===================================================================
echo   TRAVEL_APP — Ung Dung Kham Pha & Sinh Ton Da Ngoai
echo ===================================================================
echo [1/2] Dang kiem tra may chu cuc bo...

netstat -ano | findstr :8080 >nul 2>&1
if %errorlevel% neq 0 (
    echo Dang khoi dong may chu port 8080...
    start /b python -m http.server 8080 --directory "build\web" >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo [2/2] Dang mo ung dung trong khung hinh di dong...

if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --app=http://localhost:8080 --window-size=430,920
) else if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app=http://localhost:8080 --window-size=430,920
) else (
    start http://localhost:8080
)

echo Hoan tat! Ban co the trai nghiem ung dung ngay tren man hinh.
