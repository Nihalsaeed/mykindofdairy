# MyKindOfDiary

A simple, elegant, and private offline journal for daily reflections.

[![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/your-username/mykindofdiary/blob/main/LICENSE)

## 📝 Description

MyKindOfDiary is a personal journaling app that allows users to write, view, search, edit, and manage daily journal entries locally on their device. It emphasizes privacy, simplicity, and offline usability — no login or cloud required.

This Flutter app is a full-featured replica of an existing HTML journal application, bringing it to mobile and desktop platforms with enhanced functionality.

## 🌟 Features

### Core Functionality
- **Offline-First**: Works completely offline with persistent local storage
- **Privacy Focused**: All data stored locally on your device
- **Simple Interface**: Clean, dark-themed UI for distraction-free journaling
- **Entry Management**: Create, view, edit, and delete journal entries
- **Smart Saving**: Automatically appends to existing entries with timestamps

### Search & Organization
- **Live Search**: Instantly filter entries by date or content
- **Date Sorting**: Entries automatically sorted by date (newest first)
- **Entry Highlighting**: Search terms highlighted in results

### Import/Export
- **JSON Export**: Export all entries as JSON files to `/storage/emulated/0/mykindofdiary/`
- **JSON Import**: Import entries from previously exported JSON files
- **File Management**: Automatic organization of journal files in dedicated directory

## 🎨 UI/UX Design

- **Dark Theme**: Black background with white text for comfortable writing
- **Neon Accents**: Cyan/blue accent colors for visual appeal
- **Responsive Layout**: Works on mobile, tablet, and desktop
- **Minimalist Interface**: Clean design focused on content creation

## 📱 Screenshots
<img src="https://github.com/Nihalsaeed/mykindofdairy/blob/0908fe37c0e15c9bffdbc54f77c96d86f8c702da/assets/Screenshot_20251101-162845.png" alt="homepage" width="200"/>
![entry saved](https://github.com/Nihalsaeed/mykindofdairy/blob/0908fe37c0e15c9bffdbc54f77c96d86f8c702da/assets/Screenshot_20251101-162858.png)
![journal exportes](https://github.com/Nihalsaeed/mykindofdairy/blob/0908fe37c0e15c9bffdbc54f77c96d86f8c702da/assets/Screenshot_20251101-162909.png)




## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/mykindofdiary.git
   cd mykindofdiary
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

- **Android APK**:
  ```bash
  flutter build apk
  ```

- **iOS**:
  ```bash
  flutter build ios
  ```

- **Web**:
  ```bash
  flutter build web
  ```

## 🛠️ Technical Details

### Architecture
- **Framework**: Flutter
- **Storage**: SharedPreferences for local data persistence
- **State Management**: Built-in Flutter state management
- **File Handling**: path_provider and permission_handler for file operations

### Project Structure
```
lib/
├── main.dart
├── models/
│   └── journal_entry.dart
├── services/
│   └── storage_service.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    ├── journal_editor.dart
    ├── journal_list.dart
    └── confirmation_dialog.dart
```

### Data Model
```dart
class JournalEntry {
  final String id;      // Date in YYYY-MM-DD format
  String content;       // Journal entry content
  
  // JSON serialization methods
  Map<String, dynamic> toJson() => {'id': id, 'content': content};
  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(id: json['id'], content: json['content']);
}
```

## 🔐 Permissions

### Android
The app requires the following permissions for export/import functionality:
- `MANAGE_EXTERNAL_STORAGE` (Android 11+) for accessing shared storage
- `WRITE_EXTERNAL_STORAGE` and `READ_EXTERNAL_STORAGE` for older Android versions

## 📤 File Operations

### Export Location
Files are exported to: `/storage/emulated/0/mykindofdiary/`

### File Format
Exported files are JSON with the format:
```json
[
  {
    "id": "2025-10-26",
    "content": "Your journal entry content here..."
  }
]
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email [nihalsaeed@gmail.com] or open an issue in the repository.