@echo off
echo Initializing React Native project...

echo Creating project directory structure...
mkdir android 2>nul
mkdir ios 2>nul

echo Creating Android directory structure...
mkdir "android\app\src\main\java\com\mykindofdairymobile" 2>nul

echo Creating iOS directory structure...
mkdir "ios\MyKindOfDairyMobile" 2>nul

echo React Native project structure created!
echo To complete setup:
echo 1. Run 'npm install' to install dependencies
echo 2. For Android: Set up Android development environment
echo 3. For iOS: Set up iOS development environment (macOS only)
pause