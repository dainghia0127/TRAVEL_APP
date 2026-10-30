@echo off
title TRAVEL_APP — Ban Web Tren Trinh Duyet
cd /d "%~dp0\mobile_flutter"

echo ===================================================================
echo   TRAVEL_APP — Dang khoi chay ban Web tren trinh duyet...
echo ===================================================================

taskkill /F /IM python.exe 2>nul
start /b python -m http.server 8080 --directory "build\web" >nul 2>&1

timeout /t 2 /nobreak >nul
echo Dang mo dia chi http://localhost:8080 tren trinh duyet cua ban...

start http://localhost:8080

echo Hoan tat! Ban co the trai nghiem ung dung tren tab trinh duyet.

