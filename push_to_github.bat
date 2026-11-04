@echo off
title Push TRAVEL_APP len GitHub
cd /d "%~dp0"

echo ===================================================================
echo   TRAVEL_APP — Dang day ma nguon len GitHub...
echo ===================================================================
echo.
git push origin main
echo.
if %errorlevel% equ 0 (
    echo ===================================================================
    echo   [THANH CONG] Da day commit len GitHub thanh cong!
    echo   GitHub Actions dang tu dong bien dich file .ipa moi cho iPhone.
    echo ===================================================================
) else (
    echo ===================================================================
    echo   [LUU Y] Neu xuat hien hop thoai yeu cau dang nhap GitHub,
    echo   hay chon 'Sign in with your browser' de xac thuc.
    echo ===================================================================
)
echo.
pause

