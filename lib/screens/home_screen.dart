import 'package:flutter/material.dart';
import 'dart:io' show Platform, File, FileSystemEntity;
// import 'dart:convert';
import '../models/journal_entry.dart';
import '../services/storage_service.dart';
import '../widgets/journal_editor.dart';
import '../widgets/journal_list.dart';
import '../widgets/confirmation_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  
  List<JournalEntry> _entries = [];
  String _searchTerm = '';
  JournalEntry? _editingEntry;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    print('Loading entries in HomeScreen...');
    final entries = await _storageService.loadEntries();
    print('Loaded ${entries.length} entries in HomeScreen');
    setState(() {
      _entries = entries;
    });
    print('Updated state with ${_entries.length} entries');
  }

  Future<void> _saveEntry(JournalEntry entry) async {
    await _storageService.saveEntry(entry);
    await _loadEntries();
    setState(() {
      _editingEntry = null;
    });
  }

  Future<void> _saveOrAppendEntry(String id, String content) async {
    await _storageService.saveOrAppendEntry(id, content);
    await _loadEntries();
    setState(() {
      _editingEntry = null;
    });
  }

  Future<void> _deleteEntry(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog();
      },
    );

    if (confirm == true) {
      await _storageService.deleteEntry(id);
      await _loadEntries();
      if (_editingEntry?.id == id) {
        setState(() {
          _editingEntry = null;
        });
      }
    }
  }

  Future<void> _exportJournal() async {
    print('Export button pressed. Current entries count: ${_entries.length}');
    
    if (_entries.isEmpty) {
      print('Showing empty journal message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your journal is empty. Nothing to export.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('User initiated export (Option 3)...');
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ea5e9)),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Exporting journal to /storage/emulated/0/mykindofdiary/...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      final String? filePath = await _storageService.exportJournalOption3();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (filePath != null) {
        print('Export successful: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Journal exported successfully!\nFile saved to:\n$filePath\n\nPlease check your file manager for the file.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 15),
          ),
        );
      } else {
        print('Export returned null - showing detailed error message');
        // Check if we're on Android and suggest permission settings
        String errorMessage = 'Export failed. Please check app permissions and try again.';
        if (Platform.isAndroid) {
          errorMessage += '\n\nMake sure to grant "All files access" permission in app settings.';
          errorMessage += '\nGo to Settings > Apps > MyKindOfDiary > Permissions > Files and media > Allow';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 15),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Export failed with error: $e');
      print('Stack trace: $stackTrace');
      
      // Close loading dialog if still open
      try {
        Navigator.of(context).pop();
      } catch (e) {
        // Ignore if dialog is already closed
      }
      
      String errorMessage = 'Failed to export journal: $e';
      if (Platform.isAndroid) {
        errorMessage += '\n\nPlease check that the app has permission to access external storage.';
        errorMessage += '\nGo to Settings > Apps > MyKindOfDiary > Permissions > Files and media > Allow';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 15),
        ),
      );
    }
  }

  Future<void> _importJournal() async {
    try {
      print('Starting import process...');
      
      // Get list of available import files
      final List<FileSystemEntity> files = await _storageService.getImportFiles();
      
      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No import files found in /storage/emulated/0/mykindofdiary\n\nMake sure you have exported files in this folder.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 10),
          ),
        );
        return;
      }

      // Show file selection dialog
      final String? selectedFilePath = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFF0ea5e9), width: 1),
            ),
            title: const Text(
              'Select File to Import',
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final File file = File(files[index].path);
                  final String fileName = file.path.split('/').last;
                  final int fileSize = file.existsSync() ? file.lengthSync() : 0;
                  final DateTime lastModified = file.existsSync() ? file.lastModifiedSync() : DateTime.now();
                  
                  return Card(
                    color: Colors.black,
                    child: ListTile(
                      title: Text(
                        fileName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${lastModified.toString().split(' ')[0]} • ${(fileSize / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(file.path);
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedFilePath != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Colors.black,
              content: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ea5e9)),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Importing journal...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );

        // Import the selected file
        final List<JournalEntry>? importedEntries = 
            await _storageService.importJournalFromFile(selectedFilePath);
        
        // Close loading dialog
        Navigator.of(context).pop();
        
        if (importedEntries != null) {
          // Show success dialog with import details
          final bool? confirmImport = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFF0ea5e9), width: 1),
                ),
                title: const Text(
                  'Import Confirmation',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Found ${importedEntries.length} entries in the selected file. Do you want to import them?',
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Import',
                      style: TextStyle(color: Color(0xFF0ea5e9)),
                    ),
                  ),
                ],
              );
            },
          );

          if (confirmImport == true) {
            // Merge imported entries with existing entries
            final bool success = await _storageService.importAndMergeEntries(importedEntries);
            
            if (success) {
              // Reload entries to show the updated list
              await _loadEntries();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully imported ${importedEntries.length} entries from: $selectedFilePath'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 10),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to merge imported entries.'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to import journal. File may be corrupt or in the wrong format.\nFile: $selectedFilePath'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 10),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // Close any open dialogs
      try {
        Navigator.of(context).pop();
      } catch (e) {
        // Ignore if no dialog to close
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import journal: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MyKindOfDiary',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_upward, // Arrow up icon for export
              color: Color(0xFF0ea5e9), // Neon blue
            ),
            onPressed: _exportJournal,
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_downward, // Arrow down icon for import
              color: Color(0xFF0ea5e9), // Neon blue
            ),
            onPressed: _importJournal,
          ),
          // Temporary debug button
          IconButton(
            icon: const Icon(
              Icons.bug_report,
              color: Colors.red,
            ),
            onPressed: () async {
              print('Debug button pressed');
              print('Current entries in state: ${_entries.length}');
              for (int i = 0; i < _entries.length; i++) {
                print('State entry $i: ID=${_entries[i].id}, Content length=${_entries[i].content.length}');
              }
              
              await _storageService.debugSharedPreferences();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Debug info logged to console'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isSearchFocused 
                    ? const Color(0xFF38bdf8) // Brighter neon when focused
                    : const Color(0xFF0ea5e9), // Neon blue line
                  width: _isSearchFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search entries as you type...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchTerm = value;
                  });
                },
                onTap: () {
                  setState(() {
                    _isSearchFocused = true;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    _isSearchFocused = false;
                  });
                },
                onTapOutside: (_) {
                  setState(() {
                    _isSearchFocused = false;
                  });
                },
              ),
            ),
            
            // Journal editor
            JournalEditor(
              entry: _editingEntry,
              onSave: _saveEntry,
              onSaveOrAppend: _saveOrAppendEntry, // New callback
            ),
            
            // Entries list
            Expanded(
              child: JournalList(
                entries: _entries,
                searchTerm: _searchTerm,
                onEdit: (entry) {
                  setState(() {
                    _editingEntry = entry;
                  });
                },
                onDelete: _deleteEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}