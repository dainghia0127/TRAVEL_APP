@echo off
setlocal enabledelayedexpansion
title Push TRAVEL_APP len GitHub
cd /d "%~dp0"

echo ===================================================================
echo   TRAVEL_APP — DONG BO VA DAY MA NGUON LEN GITHUB
echo ===================================================================
echo.

:: 1. Kiem tra xem co file nao thay doi chua commit hay khong
git status --porcelain > nul 2>&1
git diff --quiet > nul 2>&1
if %errorlevel% neq 0 (
    echo [1/3] Phat hien co thay doi chua commit. Dang gom file va tao commit...
    git add -A
    git commit -m "feat: auto update and sync travel app changes"
    echo   - Da commit thanh cong cac thay doi moi nhat!
    echo.
) else (
    echo [1/3] Source code da duoc commit day du, san sang push!
    echo.
)

:: 2. Thiet lap remote dam bao dinh danh dung tai khoan chu so huu dainghia0127
echo [2/4] Kiem tra ket noi den repository dainghia0127/TRAVEL_APP...
git remote set-url origin https://dainghia0127@github.com/dainghia0127/TRAVEL_APP.git

:: 3. Tu dong keo cac commit tu dong moi nhat tren GitHub ve truoc (chong loi fetch first)
echo [3/4] Dang dong bo commit moi nhat tu GitHub ve may (git pull --rebase)...
git pull --rebase origin main
echo.

:: 4. Day commit len GitHub
echo [4/4] Dang day ma nguon len nhanh main tren GitHub...
echo.
git push origin main

set PUSH_RESULT=%errorlevel%
echo.

if %PUSH_RESULT% equ 0 (
    echo ===================================================================
    echo   [THANH CONG] Da day toan bo ma nguon len GitHub thanh cong!
    echo   - GitHub Actions dang tu dong bien dich va deploy len GitHub Pages.
    echo   - Quy trinh PWA Pages va Build iOS dang duoc khoi chay.
    echo   - Cac workflow run cu cua TRAVEL_APP se tu dong duoc don sach.
    echo ===================================================================
) else (
    echo ===================================================================
    echo   [LUU Y QUAN TRONG VE TAI KHOAN GITHUB]
    echo   Loi ma so: %PUSH_RESULT%
    echo.
    echo   Nguyen nhan thuong gap:
    echo   1. May tinh co nhieu tai khoan GitHub (vi du: NghiaNDD1 va dainghia0127).
    echo      -> BAT BUOC phai chon tai khoan: dainghia0127 (chu so huu repo).
    echo         Neu chon nham NghiaNDD1, GitHub se chan quyen (403 Permission Denied).
    echo   2. Neu trinh duyet mo ra trang xac thuc:
    echo      -> Hay bam "Sign in with your browser" va dang nhap bang dainghia0127.
    echo ===================================================================
)

echo.
echo Nhan phim bat ky de dong cua so nay...
pause >nul
pause

