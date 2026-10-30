@echo off
title TRAVEL_APP — Khoi Dong Ung Dung
cd /d "%~dp0\mobile_flutter"

echo ===================================================================
echo   TRAVEL_APP — Ung Dung Kham Pha & Sinh Ton Da Ngoai
echo ===================================================================
echo [1/2] Dang khoi dong may chu noi bo...

taskkill /F /IM python.exe 2>nul
start /b python -m http.server 8080 --directory "build\web" >nul 2>&1

timeout /t 2 /nobreak >nul
echo [2/2] Dang mo ung dung trong cua so Desktop...

start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app=http://localhost:8080 --window-size=450,900

echo Hoan tat! Ban co the trai nghiem ung dung ngay tren man hinh.

