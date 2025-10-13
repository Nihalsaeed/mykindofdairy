This PRD is based on the functionality of your `mykindofdairy.html` file and is optimized for building a **production-grade offline-first Flutter app**.

---

# 🧾 Product Requirements Document (PRD)

## 1. Product Overview

### **Product Name:**

**MyKindOfDiary**

### **Tagline:**

A simple, elegant, and private offline journal for daily reflections.

### **Description:**

MyKindOfDiary is a **personal journaling app** that allows users to **write, view, search, edit, and manage** daily journal entries locally on their device.
It emphasizes **privacy, simplicity, and offline usability** — no login or cloud required.

This Flutter app is a full-featured replica of the existing **HTML version (`mykindofdairy.html`)**, bringing it to mobile and desktop platforms.

---

## 2. Goals & Non-Goals

### 🎯 **Goals**

* Replicate all features and flows from the HTML app in Flutter.
* Enable completely **offline journaling** with persistent local storage.
* Provide a **clean, dark, distraction-free UI**.
* Allow users to **import/export** their data easily as `.json`.
* Implement **search, edit, and delete** functionality for entries.

### 🚫 **Non-Goals**

* No user authentication or cloud sync (for initial release).
* No multimedia content (text-only).
* No advanced formatting or tags in Phase 1.

---

## 3. Target Platforms

* **Primary:** Android, iOS
* **Secondary (Optional):** Flutter Web (PWA-style offline mode)

---

## 4. User Personas

| Persona                    | Description                                       | Needs                                     |
| -------------------------- | ------------------------------------------------- | ----------------------------------------- |
| **Reflective User**        | Writes short daily reflections or gratitude notes | Quick entry, easy access, no distractions |
| **Journal Enthusiast**     | Writes long entries and searches old notes        | Search, edit, delete with confidence      |
| **Privacy-Conscious User** | Prefers fully offline journaling                  | Local storage only, no cloud              |
| **Minimalist User**        | Wants a clutter-free dark interface               | Simple layout, few buttons                |

---

## 5. Core Features

### 📝 1. Journal Entry Management

* **Add/Edit Entry:**

  * Text field for writing thoughts.
  * Date picker (default: today).
  * “Save” button appends timestamp `[HH:MM]` if entry already exists.
  * Updates stored entries instantly.

* **View Entries:**

  * List of all entries sorted by date (newest first).
  * Each entry shows formatted date and full text.
  * Tap entry to load into editor for editing.

* **Delete Entry:**

  * Trash icon triggers confirmation modal before deletion.
  * On confirmation → removes entry from local storage.

---

### 🔍 2. Search

* Live search bar filters entries by:

  * Date (formatted or raw string)
  * Content (case-insensitive)
* Highlight search terms using `RichText`.

---

### 💾 3. Local Storage

* Store entries locally with Hive or SharedPreferences.
* Data model:

  ```dart
  class JournalEntry {
    String id; // "YYYY-MM-DD"
    String content;
  }
  ```
* Stored as a JSON array under key `"JournalEntries"`.
* Auto-load on app start.

---

### 📤 4. Import / Export JSON

* **Export:**

  * Converts all entries into JSON and saves as `.json` file.
  * Filename format: `journal_export_YYYY-MM-DD.json`.

* **Import:**

  * Opens file picker → selects JSON file.
  * Validates structure before replacing local data.
  * Displays success/error message.

---

### ⚙️ 5. Offline-First Operation

* Works fully offline.
* No dependencies on internet connection.
* Data persists between sessions.

---

### 💬 6. Notifications (Optional / Future)

* Option to add daily journaling reminders (Phase 2).

---

## 6. UI / UX Design

### **Theme**

* Dark minimalist interface:

  * Background: `Colors.black`
  * Text: `Colors.white` / `Colors.grey[300]`
  * Accents: Neon blue (`Colors.cyanAccent` / `sky-500` feel)
* Rounded cards and soft shadow glow.

### **Font**

* “Inter” or equivalent (`fontFamily: 'Inter'`)

### **Screen Layout**

| Section                        | Description                           |
| ------------------------------ | ------------------------------------- |
| **AppBar**                     | Title: “MyKindOfDiary”                |
| **Search Bar**                 | Top field for live search             |
| **Journal Editor Card**        | Date selector, TextField, Save button |
| **Message/Status Area**        | Shows save/delete messages            |
| **Entries List**               | Scrollable list of saved entries      |
| **Action Buttons**             | Export, Import (top right corner)     |
| **Delete Confirmation Dialog** | Appears on delete action              |

---

### **Interactions**

* **Save Button:** Saves or appends text to selected date.
* **Entry Tap:** Loads entry content for editing.
* **Delete Icon:** Opens modal for confirmation.
* **Search Field:** Filters entries live, with highlight.
* **Import/Export Buttons:** Use system file picker.

---

## 7. Technical Design

### **Architecture**

* Flutter app using **MVVM-like** separation:

  * `Model`: JournalEntry
  * `ViewModel`: StorageService
  * `UI`: HomeScreen, Editor, List Widgets

### **Project Structure**

```
lib/
 ├── main.dart
 ├── models/
 │    └── journal_entry.dart
 ├── services/
 │    └── storage_service.dart
 ├── screens/
 │    └── home_screen.dart
 ├── widgets/
 │    ├── journal_editor.dart
 │    ├── journal_list.dart
 │    └── confirmation_dialog.dart
```

---

### **Dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.0.15
  file_picker: ^6.1.1
  intl: ^0.19.0
```

---

### **Data Flow**

1. User writes → taps save → updates Hive box → UI rebuilds.
2. On search → filter in memory → update list view.
3. On delete → remove entry from storage → show Snackbar.
4. On import/export → read/write JSON file → reload UI.

---

### **Performance Requirements**

* App loads in < 2 seconds.
* Handles 1,000+ entries without lag.
* UI remains smooth at 60fps.

---

## 8. Future Enhancements (Phase 2+)

| Feature               | Description                             |
| --------------------- | --------------------------------------- |
| **Cloud Sync**        | Optional backup via Firebase.           |
| **Markdown Support**  | Allow headings, bullet points.          |
| **Tags / Categories** | Organize entries by tags.               |
| **Reminders**         | Push notification for daily journaling. |
| **Multi-device Sync** | Login and sync across devices.          |

---

## 9. Success Metrics

| Metric                | Target                      |
| --------------------- | --------------------------- |
| App Launch Time       | < 2 seconds                 |
| Data Loss Incidents   | 0                           |
| User Retention        | 80% after 7 days            |
| Crash-free Sessions   | 99.9%                       |
| Offline Functionality | 100% feature parity offline |

---

## 10. Deliverables

### Phase 1 (Current Sprint)

✅ Flutter app replicating `mykindofdairy.html`
✅ Local storage with Hive
✅ CRUD operations
✅ JSON import/export
✅ Search + highlight
✅ Confirmation dialog

### Phase 2 (Later)

🚀 UI polish, reminders, markdown support, cloud backup

---

## 11. Acceptance Criteria

* [ ] UI visually matches HTML version (dark, neon accent).
* [ ] App runs offline with no internet errors.
* [ ] Entries persist after app restart.
* [ ] Import/export JSON works correctly.
* [ ] Search filters and highlights text dynamically.
* [ ] Delete confirmation dialog behaves as expected.
* [ ] App passes Flutter analyzer (no warnings).

---


