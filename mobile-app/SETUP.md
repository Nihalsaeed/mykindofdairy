# Mobile App Setup Guide

This guide will help you properly set up and run the My Kind of Dairy mobile companion app.

## ⚠️ Important Notice

The files in this directory are a template/boilerplate for the mobile app. You need to properly initialize a React Native project to run this app.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Node.js** (version 16 or higher)
2. **npm** or **yarn**
3. **React Native CLI** (optional, as we'll use npx)
4. **Android Studio** (for Android development)
5. **Xcode** (for iOS development, macOS only)

## Complete Setup Instructions

### Step 1: Create a New React Native Project

Navigate to the parent directory and create a new React Native project:

```bash
# Navigate to the parent directory
cd ..

# Create a new React Native project
npx react-native init MyKindOfDairyMobile

# Navigate into the new project
cd MyKindOfDairyMobile
```

### Step 2: Copy Template Files

Copy the template files from the mobile-app directory to your new React Native project:

```bash
# Copy App.js from the template
cp ../mobile-app/App.js .

# Copy any other custom files you've created
```

### Step 3: Install Required Dependencies

Install all the required dependencies for file system access and navigation:

```bash
npm install react-native-fs react-native-document-picker @react-navigation/native @react-navigation/stack react-native-screens react-native-safe-area-context react-native-gesture-handler
```

### Step 4: Platform-Specific Setup

#### For iOS (macOS only):

After installing dependencies, you need to install iOS pods:

```bash
cd ios
pod install
cd ..
```

#### For Android:

No additional steps are required for Android after installing dependencies.

### Step 5: Running the App

#### For Android:

Make sure you have an Android emulator running or an Android device connected with USB debugging enabled.

```bash
npx react-native run-android
```

#### For iOS (macOS only):

```bash
npx react-native run-ios
```

## File System Access Implementation

The mobile app uses the following libraries for file system access:

1. **react-native-fs**: For reading/writing files
2. **react-native-document-picker**: For selecting directories

### Key Functions:

1. **selectJournalDirectory()**: Opens a directory picker for the user to select where journal entries are stored
2. **loadEntries()**: Reads all journal entries from the selected directory
3. **saveEntry()**: Saves a new journal entry as a JSON file
4. **deleteEntry()**: Deletes a journal entry file

### File Format:

Entries are stored as individual JSON files with the format:
```json
{
  "id": "YYYY-MM-DD",
  "content": "[HH:MM] Your journal content here"
}
```

Files are named using the convention: `entry_YYYY-MM-DD.json`

## Directory Structure Compatibility

The mobile app is designed to work with the same directory structure as the web application:

```
journal_entries/
├── entry_2025-10-01.json
├── entry_2025-10-02.json
└── entry_2025-10-03.json
```

This allows for seamless synchronization between devices when using a file sync solution like Syncthing.

## Troubleshooting

### Common Issues:

1. **"Command failed: ./gradlew app:installDebug"**
   - Try running `cd android && ./gradlew clean` then go back and run the app again

2. **"No connected devices"**
   - Ensure your Android device is connected and USB debugging is enabled
   - Or start an Android emulator

3. **"Error: EMFILE: too many open files"**
   - This can happen on macOS; try increasing the file descriptor limit

4. **iOS build failures**
   - Try running `cd ios && pod install` then go back and run the app

5. **"Android project not found"**
   - This means the React Native project wasn't properly initialized
   - Follow the complete setup instructions above

### Development Tips:

1. Use React Native Debugger for easier debugging
2. Enable Live Reload and Hot Reloading for faster development
3. Use the React DevTools to inspect component hierarchy

## Testing

The project includes a test file (`test-file-access.js`) that verifies the file system access functionality. You can run it with:

```bash
node ../mobile-app/test-file-access.js
```

This will simulate file operations without requiring a full React Native environment.