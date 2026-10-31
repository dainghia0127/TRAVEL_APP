@echo off
title TRAVEL_APP — Ban Web Tren Trinh Duyet
cd /d "%~dp0\mobile_flutter"

echo ===================================================================
echo   TRAVEL_APP — Dang khoi chay ban Web tren trinh duyet...
echo ===================================================================

netstat -ano | findstr :8080 >nul 2>&1
if %errorlevel% neq 0 (
    echo Dang khoi dong may chu port 8080...
    start /b python -m http.server 8080 --directory "build\web" >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo Dang mo dia chi http://localhost:8080 tren trinh duyet cua ban...
start http://localhost:8080

echo Hoan tat! Ban co the trai nghiem ung dung tren tab trinh duyet.
