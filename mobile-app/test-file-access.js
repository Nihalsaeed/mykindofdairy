/**
 * Test file for verifying file system access functionality
 */

// Mock implementation of RNFS for testing purposes
const RNFS = {
  async readDir(directoryPath) {
    // Mock implementation - in real app this would read actual directory
    console.log(`Reading directory: ${directoryPath}`);
    return [
      { name: 'entry_2025-10-01.json', path: `${directoryPath}/entry_2025-10-01.json` },
      { name: 'entry_2025-10-02.json', path: `${directoryPath}/entry_2025-10-02.json` },
      { name: 'entry_2025-10-03.json', path: `${directoryPath}/entry_2025-10-03.json` },
      { name: 'other-file.txt', path: `${directoryPath}/other-file.txt` }
    ];
  },

  async readFile(filePath, encoding) {
    // Mock implementation - in real app this would read actual file
    console.log(`Reading file: ${filePath} with encoding: ${encoding}`);
    const fileName = filePath.split('/').pop();
    
    // Return mock content based on file name
    switch (fileName) {
      case 'entry_2025-10-01.json':
        return JSON.stringify({
          id: '2025-10-01',
          content: '[17:52] rijfbewrfboerbr'
        });
      case 'entry_2025-10-02.json':
        return JSON.stringify({
          id: '2025-10-02',
          content: '[09:15] Working on mobile app development'
        });
      case 'entry_2025-10-03.json':
        return JSON.stringify({
          id: '2025-10-03',
          content: '[14:30] Testing file system access functionality'
        });
      default:
        throw new Error('File not found');
    }
  },

  async writeFile(filePath, content, encoding) {
    // Mock implementation - in real app this would write actual file
    console.log(`Writing file: ${filePath} with content: ${content} and encoding: ${encoding}`);
    return true;
  },

  async exists(path) {
    // Mock implementation - in real app this would check if path exists
    console.log(`Checking if path exists: ${path}`);
    return true;
  },

  async unlink(filePath) {
    // Mock implementation - in real app this would delete actual file
    console.log(`Deleting file: ${filePath}`);
    return true;
  }
};

// Mock implementation of DocumentPicker for testing purposes
const DocumentPicker = {
  async pickDirectory() {
    // Mock implementation - in real app this would open directory picker
    console.log('Opening directory picker');
    return { uri: 'file:///test/journal_entries' };
  },

  isCancel(error) {
    return error && error.message === 'User canceled';
  }
};

// Test functions
async function testLoadEntries() {
  console.log('Testing loadEntries function...');
  
  try {
    const journalDirectory = 'file:///test/journal_entries';
    const files = await RNFS.readDir(journalDirectory);
    const journalEntries = [];

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
    
    console.log('Loaded entries:', journalEntries);
    return journalEntries;
  } catch (error) {
    console.error('Error in testLoadEntries:', error);
  }
}

async function testSaveEntry() {
  console.log('Testing saveEntry function...');
  
  try {
    const entry = {
      id: '2025-10-04',
      content: '[16:45] This is a test entry'
    };

    const journalDirectory = 'file:///test/journal_entries';
    const fileName = `entry_${entry.id}.json`;
    const filePath = `${journalDirectory}/${fileName}`;

    const fileContent = JSON.stringify(entry, null, 2);
    await RNFS.writeFile(filePath, fileContent, 'utf8');
    
    console.log('Entry saved successfully:', entry);
    return true;
  } catch (error) {
    console.error('Error in testSaveEntry:', error);
    return false;
  }
}

// Run tests
async function runTests() {
  console.log('Running file system access tests...\n');
  
  await testLoadEntries();
  console.log('\n-------------------\n');
  await testSaveEntry();
  
  console.log('\nAll tests completed!');
}

// Export for use in other files
module.exports = {
  RNFS,
  DocumentPicker,
  testLoadEntries,
  testSaveEntry,
  runTests
};

// Run tests if this file is executed directly
if (require.main === module) {
  runTests();
}