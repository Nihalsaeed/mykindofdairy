# My Kind of Dairy - Mobile App

A mobile companion app for the My Kind of Dairy journal application with native file system access.

## ⚠️ Important Notice

This is currently a template/boilerplate for the mobile app. To run this app, you'll need to properly initialize a React Native project.

## Features

- Native file system access to read/write journal entries
- Same file format as the web application (`entry_YYYY-MM-DD.json`)
- Offline-first functionality
- Search through entries
- Create, edit, and delete journal entries
- Dark theme with neon blue accents

## Prerequisites

- Node.js (version 16 or higher)
- npm or yarn
- React Native development environment set up for iOS and/or Android

## Complete Setup Instructions

Since this is a template, you'll need to properly set up the React Native project:

1. Create a new React Native project:
   ```bash
   npx react-native init MyKindOfDairyMobile
   ```

2. Copy the source files from this template to the new project:
   - Copy `App.js` to the new project directory
   - Copy any other custom components or utilities

3. Install required dependencies:
   ```bash
   npm install react-native-fs react-native-document-picker @react-navigation/native @react-navigation/stack react-native-screens react-native-safe-area-context react-native-gesture-handler
   ```

4. For iOS, also run:
   ```bash
   cd ios && pod install
   ```

## File System Integration

The app uses `react-native-fs` for file system access and `react-native-document-picker` for directory selection. Journal entries are stored as individual JSON files with the format:

```json
{
  "id": "YYYY-MM-DD",
  "content": "[HH:MM] Your journal content here"
}
```

Files are named using the convention: `entry_YYYY-MM-DD.json`

## Directory Structure

```
mobile-app/
├── App.js              # Main application component
├── index.js            # Entry point
├── app.json            # App configuration
├── package.json        # Dependencies and scripts
├── babel.config.js     # Babel configuration
├── metro.config.js     # Metro bundler configuration
└── README.md           # This file
```

## Compatibility

This mobile app is designed to work with the same journal entries as the web application, allowing for seamless synchronization between devices when using a file sync solution like Syncthing.

## Troubleshooting

If you encounter issues:

1. Make sure you have the React Native development environment properly set up
2. Check that all dependencies are installed correctly
3. For Android, ensure you have Android Studio and the Android SDK installed
4. For iOS, ensure you have Xcode installed (macOS only)