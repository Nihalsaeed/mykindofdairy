import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/journal_entry.dart';

class StorageService {
  static const String _storageKey = 'JournalEntries';

  // Load all entries from local storage
  Future<List<JournalEntry>> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString(_storageKey);
      
      print('Loading entries from SharedPreferences...');
      print('Storage key: $_storageKey');
      print('Entries JSON exists: ${entriesJson != null}');
      
      if (entriesJson == null || entriesJson.isEmpty) {
        print('No entries found in storage');
        return [];
      }
      
      print('Entries JSON length: ${entriesJson.length}');

      try {
        final List<dynamic> jsonList = json.decode(entriesJson);
        print('Parsed JSON list with ${jsonList.length} items');
        
        final List<JournalEntry> entries = jsonList
            .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Converted to JournalEntry list with ${entries.length} items');

        // Sort by date (newest first)
        entries.sort((a, b) => b.id.compareTo(a.id));
        print('Sorted entries by date');
        
        return entries;
      } catch (e) {
        print('Error parsing JSON: $e');
        // Return empty list if there's an error parsing
        return [];
      }
    } catch (e, stackTrace) {
      print('Error loading entries: $e');
      print('Stack trace: $stackTrace');
      // Return empty list if there's an error
      return [];
    }
  }

  // Save all entries to local storage
  Future<void> saveEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        entries.map((entry) => entry.toJson()).toList();
    final String jsonString = json.encode(jsonList);
    await prefs.setString(_storageKey, jsonString);
  }

  // Add or update an entry
  Future<void> saveEntry(JournalEntry entry) async {
    final entries = await loadEntries();
    final existingIndex =
        entries.indexWhere((existingEntry) => existingEntry.id == entry.id);

    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }

    // Sort by date (newest first)
    entries.sort((a, b) => b.id.compareTo(a.id));
    await saveEntries(entries);
  }

  // Add or append to an entry - this is the key method to fix the issue
  Future<void> saveOrAppendEntry(String id, String newContent) async {
    final entries = await loadEntries();
    final existingIndex =
        entries.indexWhere((existingEntry) => existingEntry.id == id);

    if (existingIndex >= 0) {
      // Append new content to existing content with proper spacing
      entries[existingIndex].content += '\n\n$newContent';
    } else {
      // Create new entry with the content (timestamp already included in newContent)
      entries.add(JournalEntry(id: id, content: newContent));
    }

    // Sort by date (newest first)
    entries.sort((a, b) => b.id.compareTo(a.id));
    await saveEntries(entries);
  }

  // Delete an entry by ID
  Future<void> deleteEntry(String id) async {
    final entries = await loadEntries();
    entries.removeWhere((entry) => entry.id == id);
    await saveEntries(entries);
  }

  // Check and request necessary permissions for Android
  Future<bool> _requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true; // No special permissions needed for other platforms
    }
    
    print('Checking storage permissions for Android...');
    
    // Check current permission status
    final PermissionStatus manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    final PermissionStatus storageStatus = await Permission.storage.status;
    
    print('MANAGE_EXTERNAL_STORAGE status: ${manageExternalStorageStatus.name}');
    print('STORAGE status: ${storageStatus.name}');
    
    // If we already have the necessary permissions, return true
    if (manageExternalStorageStatus.isGranted || storageStatus.isGranted) {
      print('Storage permissions already granted');
      return true;
    }
    
    // For Android 11 and above, we need MANAGE_EXTERNAL_STORAGE
    if (manageExternalStorageStatus.isPermanentlyDenied) {
      print('MANAGE_EXTERNAL_STORAGE permanently denied, opening app settings...');
      await openAppSettings();
      return false;
    }
    
    if (storageStatus.isPermanentlyDenied) {
      print('STORAGE permission permanently denied, opening app settings...');
      await openAppSettings();
      return false;
    }
    
    // Request permissions
    print('Requesting storage permissions...');
    
    // Try MANAGE_EXTERNAL_STORAGE first (for Android 11+)
    print('Requesting MANAGE_EXTERNAL_STORAGE permission...');
    PermissionStatus manageStatus = await Permission.manageExternalStorage.request();
    print('MANAGE_EXTERNAL_STORAGE permission status: ${manageStatus.name}');
    
    // If that fails, try regular storage permission
    if (!manageStatus.isGranted) {
      print('MANAGE_EXTERNAL_STORAGE not granted, requesting STORAGE permission...');
      PermissionStatus storageStatus = await Permission.storage.request();
      print('STORAGE permission status: ${storageStatus.name}');
      
      // If still not granted and permanently denied, open settings
      if (storageStatus.isPermanentlyDenied) {
        print('STORAGE permission permanently denied, opening app settings...');
        await openAppSettings();
        return false;
      }
      
      // Return whether we got at least one permission
      return storageStatus.isGranted;
    }
    
    // If MANAGE_EXTERNAL_STORAGE was denied but not permanently, try once more
    if (manageStatus.isDenied) {
      print('MANAGE_EXTERNAL_STORAGE denied, trying once more...');
      manageStatus = await Permission.manageExternalStorage.request();
      print('Second attempt MANAGE_EXTERNAL_STORAGE permission status: ${manageStatus.name}');
    }
    
    return manageStatus.isGranted;
  }

  // Export journal entries to a JSON file in the specific mykindofdiary directory (Option 3)
  Future<String?> exportJournalOption3() async {
    try {
      print('=== Starting Option 3 Export ===');
      
      final entries = await loadEntries();
      print('Loaded ${entries.length} entries for export');
      
      if (entries.isEmpty) {
        print('No entries to export');
        return null;
      }

      // Convert entries to JSON
      final List<Map<String, dynamic>> jsonList =
          entries.map((entry) => entry.toJson()).toList();
      final String jsonString = json.encode(jsonList, toEncodable: (dynamic item) => item.toString());
      print('JSON created, length: ${jsonString.length}');

      // For Android, we need to handle permissions properly
      if (Platform.isAndroid) {
        print('Using Android-specific export approach...');
        
        // Check permissions first
        print('Checking storage permissions for Android...');
        final PermissionStatus manageExternalStorageStatus = await Permission.manageExternalStorage.status;
        final PermissionStatus storageStatus = await Permission.storage.status;
        
        print('MANAGE_EXTERNAL_STORAGE status: ${manageExternalStorageStatus.name}');
        print('STORAGE status: ${storageStatus.name}');
        
        bool hasPermission = false;
        
        // If we already have the necessary permissions
        if (manageExternalStorageStatus.isGranted || storageStatus.isGranted) {
          print('Storage permissions already granted');
          hasPermission = true;
        } else {
          // Request permissions if not granted
          print('Requesting storage permissions...');
          final PermissionStatus manageStatus = await Permission.manageExternalStorage.request();
          print('MANAGE_EXTERNAL_STORAGE permission status after request: ${manageStatus.name}');
          
          if (manageStatus.isGranted) {
            hasPermission = true;
          } else {
            // Try regular storage permission as fallback
            final PermissionStatus storageStatus = await Permission.storage.request();
            print('STORAGE permission status after request: ${storageStatus.name}');
            hasPermission = storageStatus.isGranted;
          }
        }
        
        // Try to access the shared storage
        print('Attempting to access shared storage...');
        try {
          final Directory exportDir = Directory('/storage/emulated/0/mykindofdiary');
          print('Target directory: ${exportDir.path}');
          
          // Check if directory exists, create if not
          if (!(await exportDir.exists())) {
            print('Directory does not exist, attempting to create...');
            try {
              await exportDir.create(recursive: true);
              print('Directory created successfully');
            } catch (dirError) {
              print('Failed to create directory: $dirError');
              // Try alternative approach
              throw dirError;
            }
          } else {
            print('Directory already exists');
          }

          // Create filename with timestamp
          final DateTime now = DateTime.now();
          final String timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
          final String fileName = 'mykindofdiary_export_$timestamp.json';
          final File file = File('${exportDir.path}/$fileName');
          print('Export file path: ${file.path}');

          // Write JSON to file
          print('Attempting to write file...');
          await file.writeAsString(jsonString);
          print('File write operation completed');

          // Verify file exists and get its size
          print('Verifying file existence...');
          if (await file.exists()) {
            final int size = await file.length();
            print('File verified successfully, size: $size bytes');
            return file.path;
          } else {
            print('File verification failed - file does not exist at ${file.path}');
            // List contents of directory to see what's there
            try {
              final List<FileSystemEntity> contents = exportDir.listSync();
              print('Directory contents (${contents.length} items):');
              for (final entity in contents) {
                print('  - ${entity.path}');
              }
            } catch (listError) {
              print('Failed to list directory contents: $listError');
            }
            return null;
          }
        } catch (e, stackTrace) {
          print('Shared storage approach failed: $e');
          print('Stack trace: $stackTrace');
          
          // If permissions were granted but we still failed, try app-specific storage
          if (hasPermission) {
            print('Trying app-specific storage as fallback...');
            try {
              final Directory? appDir = await getExternalStorageDirectory();
              if (appDir != null) {
                print('App external storage directory: ${appDir.path}');
                
                final Directory appExportDir = Directory('${appDir.path}/mykindofdiary');
                if (!(await appExportDir.exists())) {
                  await appExportDir.create(recursive: true);
                  print('Created app-specific directory: ${appExportDir.path}');
                }
                
                // Create filename with timestamp
                final DateTime now = DateTime.now();
                final String timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
                final String fileName = 'mykindofdiary_export_$timestamp.json';
                final File file = File('${appExportDir.path}/$fileName');
                print('App-specific export file: ${file.path}');

                // Write JSON to file
                await file.writeAsString(jsonString);
                print('App-specific file written successfully');

                // Verify file exists and get its size
                if (await file.exists()) {
                  final int size = await file.length();
                  print('App-specific file verified, size: $size bytes');
                  return file.path;
                }
              }
            } catch (appError, appStack) {
              print('App-specific storage approach failed: $appError');
              print('Stack trace: $appStack');
            }
          }
          
          return null;
        }
      } else {
        // For non-Android platforms, use a simpler approach
        final Directory? appDocDir = await getApplicationDocumentsDirectory();
        if (appDocDir != null) {
          final Directory exportDir = Directory('${appDocDir.path}/mykindofdiary');
          if (!(await exportDir.exists())) {
            await exportDir.create(recursive: true);
          }
          
          final DateTime now = DateTime.now();
          final String timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
          final String fileName = 'mykindofdiary_export_$timestamp.json';
          final File file = File('${exportDir.path}/$fileName');
          
          await file.writeAsString(jsonString);
          
          if (await file.exists()) {
            return file.path;
          }
        }
        return null;
      }
    } catch (e, stackTrace) {
      print('Export failed: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Main export method that uses Option 3
  Future<String?> exportJournal() async {
    return await exportJournalOption3();
  }

  // Import journal entries from a JSON file
  Future<List<JournalEntry>?> importJournalFromFile(String filePath) async {
    try {
      final File file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        return null;
      }

      // Read the file content
      final String jsonString = await file.readAsString();
      
      // Parse the JSON
      final dynamic parsedJson = json.decode(jsonString);
      
      // Handle different JSON formats
      List<dynamic> jsonList;
      
      if (parsedJson is List) {
        // Already a list format
        jsonList = parsedJson;
      } else if (parsedJson is Map && parsedJson.containsKey('entries')) {
        // Object with entries array
        jsonList = parsedJson['entries'] as List;
      } else {
        // Try to convert single object to list
        jsonList = [parsedJson];
      }
      
      // Convert to JournalEntry objects with validation
      final List<JournalEntry> entries = [];
      
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            // Try direct conversion first
            final JournalEntry entry = JournalEntry.fromJson(item);
            entries.add(entry);
          } catch (e) {
            // If direct conversion fails, try to extract id and content
            final String? id = item['id'] as String? ?? item['date'] as String?;
            final String? content = item['content'] as String? ?? item['text'] as String? ?? item['body'] as String?;
            
            // Validate that we have both id and content
            if (id != null && content != null) {
              // Validate date format (should be YYYY-MM-DD)
              if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(id) || 
                  RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(id)) {
                // Convert date format if needed
                String formattedId = id;
                if (id.contains('/')) {
                  final parts = id.split('/');
                  formattedId = '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
                }
                
                entries.add(JournalEntry(id: formattedId, content: content));
              } else {
                // If id is not a date, use current date as id and combine id with content
                final String currentDate = DateTime.now().toIso8601String().split('T')[0];
                entries.add(JournalEntry(id: currentDate, content: '$id: $content'));
              }
            }
          }
        }
      }

      return entries.isNotEmpty ? entries : null;
    } catch (e) {
      // Log the error but don't crash the app
      print('Error importing journal: $e');
      return null;
    }
  }

  // Get list of JSON files in the import directory
  Future<List<FileSystemEntity>> getImportFiles() async {
    try {
      // Use the same directory as export for consistency
      final Directory importDir = Directory('/storage/emulated/0/mykindofdiary');
      
      // Check if directory exists
      final bool dirExists = await importDir.exists();
      print('Import directory exists: $dirExists');
      print('Import directory path: ${importDir.path}');
      
      if (!dirExists) {
        print('Import directory does not exist: ${importDir.path}');
        // Try to create it
        try {
          await importDir.create(recursive: true);
          print('Import directory created successfully');
        } catch (e) {
          print('Failed to create import directory: $e');
          // Try alternative approach for Android
          if (Platform.isAndroid) {
            try {
              final Directory? externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                final Directory altImportDir = Directory('${externalDir.path}/mykindofdiary');
                if (await altImportDir.exists()) {
                  print('Using alternative import directory: ${altImportDir.path}');
                  // List files from alternative directory
                  final List<FileSystemEntity> files = altImportDir.listSync()
                      .where((entity) => entity is File && entity.path.toLowerCase().endsWith('.json'))
                      .toList();
                  
                  // Sort by modification time (newest first)
                  files.sort((a, b) {
                    try {
                      final File fileA = File(a.path);
                      final File fileB = File(b.path);
                      return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
                    } catch (e) {
                      print('Error comparing file dates: $e');
                      return 0;
                    }
                  });
                  
                  return files;
                }
              }
            } catch (altE) {
              print('Alternative approach also failed: $altE');
            }
          }
          return [];
        }
      }

      // List all JSON files in the directory
      final List<FileSystemEntity> files = importDir.listSync()
          .where((entity) => entity is File && entity.path.toLowerCase().endsWith('.json'))
          .toList();

      // Sort by modification time (newest first)
      files.sort((a, b) {
        try {
          final File fileA = File(a.path);
          final File fileB = File(b.path);
          return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
        } catch (e) {
          print('Error comparing file dates: $e');
          return 0;
        }
      });

      print('Found ${files.length} JSON files in import directory');
      for (final file in files) {
        print('  - ${file.path}');
      }

      return files;
    } catch (e, stackTrace) {
      // Log the error but don't crash the app
      print('Error getting import files: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Import entries and merge with existing entries
  Future<bool> importAndMergeEntries(List<JournalEntry> importedEntries) async {
    try {
      // Load existing entries
      final List<JournalEntry> existingEntries = await loadEntries();
      
      // Merge entries (imported entries will overwrite existing ones with same ID)
      final Map<String, JournalEntry> entryMap = {};
      
      // Add existing entries first
      for (final entry in existingEntries) {
        entryMap[entry.id] = entry;
      }
      
      // Add or overwrite with imported entries
      for (final entry in importedEntries) {
        entryMap[entry.id] = entry;
      }
      
      // Convert back to list
      final List<JournalEntry> mergedEntries = entryMap.values.toList();
      
      // Sort by date (newest first)
      mergedEntries.sort((a, b) => b.id.compareTo(a.id));
      
      // Save merged entries
      await saveEntries(mergedEntries);
      
      return true;
    } catch (e) {
      // Log the error but don't crash the app
      print('Error merging entries: $e');
      return false;
    }
  }
}