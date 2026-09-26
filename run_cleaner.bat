@echo off
title Android Storage Cleaner via ADB
cd /d "%~dp0"
echo ===================================================
echo     Android Storage Cleaner (ADB Auto Clean)
echo ===================================================
powershell -ExecutionPolicy Bypass -File "%~dp0clean_android.ps1"
echo.
pause
