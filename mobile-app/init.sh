#!/bin/bash

# Initialize React Native project
echo "Initializing React Native project..."

# Create the basic project structure
mkdir -p android ios

# Create basic Android files
echo "Creating Android directory structure..."
mkdir -p android/app/src/main/java/com/mykindofdairymobile

# Create basic iOS files
echo "Creating iOS directory structure..."
mkdir -p ios/MyKindOfDairyMobile

echo "React Native project structure created!"
echo "To complete setup:"
echo "1. Run 'npm install' to install dependencies"
echo "2. For Android: Set up Android development environment"
echo "3. For iOS: Set up iOS development environment (macOS only)"