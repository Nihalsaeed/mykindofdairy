@echo off
title My Kind of Dairy Mobile App Setup

echo My Kind of Dairy Mobile App Setup Script
echo ========================================
echo.

echo This script will help you set up the React Native project properly.
echo.

echo Prerequisites:
echo - Node.js (version 16 or higher) must be installed
echo - Android Studio for Android development
echo - Xcode for iOS development (macOS only)
echo.

echo Press any key to continue...
pause >nul

echo.
echo Setting up the project...
echo.

REM Bypass execution policy for this script
powershell -ExecutionPolicy Bypass -Command "node setup-project.js"

echo.
echo Setup process completed.
echo Please check the messages above for any errors.
echo.
echo Press any key to exit...
pause >nul