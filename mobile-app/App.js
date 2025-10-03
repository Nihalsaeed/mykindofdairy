import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  FlatList,
  Alert,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import RNFS from 'react-native-fs';
import DocumentPicker from 'react-native-document-picker';

const App = () => {
  const [entries, setEntries] = useState([]);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [content, setContent] = useState('');
  const [journalDirectory, setJournalDirectory] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');

  // Load entries when directory is set
  useEffect(() => {
    if (journalDirectory) {
      loadEntries();
    }
  }, [journalDirectory]);

  // Function to select journal directory
  const selectJournalDirectory = async () => {
    try {
      const res = await DocumentPicker.pickDirectory();
      setJournalDirectory(res.uri);
      Alert.alert('Success', 'Journal directory selected successfully!');
    } catch (err) {
      if (DocumentPicker.isCancel(err)) {
        // User cancelled the picker
      } else {
        Alert.alert('Error', 'Failed to select directory: ' + err.message);
      }
    }
  };

  // Function to load journal entries from directory
  const loadEntries = async () => {
    try {
      // Check if directory exists
      const exists = await RNFS.exists(journalDirectory);
      if (!exists) {
        Alert.alert('Error', 'Selected directory does not exist');
        return;
      }

      // Read directory contents
      const files = await RNFS.readDir(journalDirectory);
      const journalEntries = [];

      // Process each file
      for (const file of files) {
        if (file.name.endsWith('.json') && file.name.startsWith('entry_')) {
          try {
            const fileContent = await RNFS.readFile(file.path, 'utf8');
            const entry = JSON.parse(fileContent);
            if (entry.id && entry.content) {
              journalEntries.push(entry);
            }
          } catch (error) {
            console.error('Error reading file:', file.name, error);
          }
        }
      }

      // Sort entries by date (newest first)
      journalEntries.sort((a, b) => b.id.localeCompare(a.id));
      setEntries(journalEntries);
    } catch (error) {
      Alert.alert('Error', 'Failed to load entries: ' + error.message);
    }
  };

  // Function to save journal entry
  const saveEntry = async () => {
    if (!journalDirectory) {
      Alert.alert('Error', 'Please select a journal directory first');
      return;
    }

    if (!content.trim()) {
      Alert.alert('Error', 'Please enter some content');
      return;
    }

    try {
      // Create entry object
      const entry = {
        id: selectedDate,
        content: `[${new Date().toLocaleTimeString()}] ${content}`,
      };

      // Create filename
      const fileName = `entry_${selectedDate}.json`;
      const filePath = `${journalDirectory}/${fileName}`;

      // Write file
      const fileContent = JSON.stringify(entry, null, 2);
      await RNFS.writeFile(filePath, fileContent, 'utf8');

      // Reload entries
      await loadEntries();

      // Clear content
      setContent('');

      Alert.alert('Success', 'Entry saved successfully!');
    } catch (error) {
      Alert.alert('Error', 'Failed to save entry: ' + error.message);
    }
  };

  // Function to delete entry
  const deleteEntry = async (entryId) => {
    try {
      const fileName = `entry_${entryId}.json`;
      const filePath = `${journalDirectory}/${fileName}`;

      // Check if file exists
      const exists = await RNFS.exists(filePath);
      if (exists) {
        await RNFS.unlink(filePath);
        await loadEntries();
        Alert.alert('Success', 'Entry deleted successfully!');
      } else {
        Alert.alert('Error', 'Entry file not found');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to delete entry: ' + error.message);
    }
  };

  // Function to confirm delete
  const confirmDelete = (entryId) => {
    Alert.alert(
      'Confirm Delete',
      'Are you sure you want to delete this entry?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => deleteEntry(entryId) },
      ]
    );
  };

  // Function to edit entry
  const editEntry = (entry) => {
    setSelectedDate(entry.id);
    setContent(entry.content);
  };

  // Filter entries based on search query
  const filteredEntries = entries.filter(entry => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase();
    return entry.content.toLowerCase().includes(query) || entry.id.includes(query);
  });

  // Render entry item
  const renderEntry = ({ item }) => (
    <View style={styles.entryCard}>
      <View style={styles.entryHeader}>
        <Text style={styles.entryDate}>{item.id}</Text>
        <View style={styles.entryActions}>
          <TouchableOpacity onPress={() => editEntry(item)} style={styles.editButton}>
            <Text style={styles.editButtonText}>Edit</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => confirmDelete(item.id)} style={styles.deleteButton}>
            <Text style={styles.deleteButtonText}>Delete</Text>
          </TouchableOpacity>
        </View>
      </View>
      <Text style={styles.entryContent}>{item.content}</Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#000" />
      
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>My Kind of Dairy</Text>
        <TouchableOpacity onPress={selectJournalDirectory} style={styles.selectDirButton}>
          <Text style={styles.selectDirButtonText}>
            {journalDirectory ? 'Change Directory' : 'Select Directory'}
          </Text>
        </TouchableOpacity>
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder="Search entries..."
          placeholderTextColor="#999"
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      {/* Entry Form */}
      <View style={styles.formContainer}>
        <View style={styles.dateContainer}>
          <Text style={styles.dateLabel}>Date:</Text>
          <TextInput
            style={styles.dateInput}
            value={selectedDate}
            onChangeText={setSelectedDate}
            placeholder="YYYY-MM-DD"
          />
        </View>
        
        <TextInput
          style={styles.contentInput}
          placeholder="Write about your day..."
          placeholderTextColor="#999"
          multiline
          numberOfLines={6}
          textAlignVertical="top"
          value={content}
          onChangeText={setContent}
        />
        
        <TouchableOpacity onPress={saveEntry} style={styles.saveButton}>
          <Text style={styles.saveButtonText}>Save Entry</Text>
        </TouchableOpacity>
      </View>

      {/* Entries List */}
      <View style={styles.entriesContainer}>
        <Text style={styles.entriesTitle}>Journal Entries</Text>
        {journalDirectory ? (
          <FlatList
            data={filteredEntries}
            renderItem={renderEntry}
            keyExtractor={(item) => item.id}
            style={styles.entriesList}
            contentContainerStyle={filteredEntries.length === 0 ? styles.emptyContainer : null}
            ListEmptyComponent={
              <Text style={styles.emptyText}>
                {searchQuery ? 'No entries match your search' : 'No journal entries found'}
              </Text>
            }
          />
        ) : (
          <View style={styles.noDirectoryContainer}>
            <Text style={styles.noDirectoryText}>
              Please select a journal directory to view your entries
            </Text>
            <TouchableOpacity onPress={selectJournalDirectory} style={styles.selectDirButtonLarge}>
              <Text style={styles.selectDirButtonTextLarge}>Select Directory</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#000',
    borderBottomWidth: 1,
    borderBottomColor: '#0ea5e9',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
  },
  selectDirButton: {
    backgroundColor: '#0ea5e9',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 6,
  },
  selectDirButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
  searchContainer: {
    padding: 16,
    backgroundColor: '#000',
  },
  searchInput: {
    backgroundColor: '#111',
    borderWidth: 1,
    borderColor: '#0ea5e9',
    borderRadius: 8,
    padding: 12,
    color: '#fff',
  },
  formContainer: {
    padding: 16,
    backgroundColor: '#000',
    borderBottomWidth: 1,
    borderBottomColor: '#0ea5e9',
  },
  dateContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  dateLabel: {
    color: '#0ea5e9',
    marginRight: 8,
    fontWeight: '600',
  },
  dateInput: {
    flex: 1,
    backgroundColor: '#111',
    borderWidth: 1,
    borderColor: '#0ea5e9',
    borderRadius: 6,
    padding: 8,
    color: '#fff',
  },
  contentInput: {
    backgroundColor: '#111',
    borderWidth: 1,
    borderColor: '#0ea5e9',
    borderRadius: 8,
    padding: 12,
    color: '#fff',
    marginBottom: 12,
    minHeight: 120,
  },
  saveButton: {
    backgroundColor: '#0ea5e9',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  saveButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 16,
  },
  entriesContainer: {
    flex: 1,
    backgroundColor: '#000',
  },
  entriesTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    padding: 16,
    paddingBottom: 8,
  },
  entriesList: {
    flex: 1,
  },
  entryCard: {
    backgroundColor: '#111',
    marginHorizontal: 16,
    marginVertical: 8,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#0ea5e9',
    padding: 12,
  },
  entryHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  entryDate: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#0ea5e9',
  },
  entryActions: {
    flexDirection: 'row',
  },
  editButton: {
    backgroundColor: '#38bdf8',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 8,
  },
  editButtonText: {
    color: '#000',
    fontWeight: '600',
    fontSize: 12,
  },
  deleteButton: {
    backgroundColor: '#ef4444',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  deleteButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 12,
  },
  entryContent: {
    color: '#ccc',
    lineHeight: 20,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    color: '#999',
    textAlign: 'center',
    fontSize: 16,
  },
  noDirectoryContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  noDirectoryText: {
    color: '#999',
    textAlign: 'center',
    fontSize: 16,
    marginBottom: 24,
  },
  selectDirButtonLarge: {
    backgroundColor: '#0ea5e9',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  selectDirButtonTextLarge: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 16,
  },
});

export default App;