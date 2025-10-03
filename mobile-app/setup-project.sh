#!/bin/bash

echo "My Kind of Dairy Mobile App Setup Script"
echo "========================================"
echo

echo "This script will help you set up the React Native project properly."
echo

echo "Prerequisites:"
echo "- Node.js (version 16 or higher) must be installed"
echo "- Android Studio for Android development"
echo "- Xcode for iOS development (macOS only)"
echo

read -p "Press Enter to continue..."

echo
echo "Setting up the project..."
echo

node setup-project.js

echo
echo "Setup process completed."
echo "Please check the messages above for any errors."
echo
read -p "Press Enter to exit..."