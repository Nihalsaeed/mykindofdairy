/**
 * Script to verify that all required files for the mobile app are present
 */

const fs = require('fs');
const path = require('path');

// List of required files
const requiredFiles = [
  'App.js',
  'index.js',
  'app.json',
  'package.json',
  'babel.config.js',
  'metro.config.js',
  'README.md',
  'SETUP.md'
];

// List of optional files (nice to have but not required)
const optionalFiles = [
  'init.sh',
  'init.bat',
  'test-file-access.js',
  'setup-project.js',
  'setup-project.bat',
  'setup-project.sh'
];

function checkFileExists(filePath) {
  try {
    fs.accessSync(filePath, fs.constants.F_OK);
    return true;
  } catch (err) {
    return false;
  }
}

function verifySetup() {
  console.log('Verifying My Kind of Dairy Mobile App Setup...\n');
  
  let allRequiredFilesPresent = true;
  
  // Check required files
  console.log('Checking required files:');
  requiredFiles.forEach(file => {
    const filePath = path.join(__dirname, file);
    const exists = checkFileExists(filePath);
    const status = exists ? '✓' : '✗';
    console.log(`  ${status} ${file}`);
    if (!exists) {
      allRequiredFilesPresent = false;
    }
  });
  
  console.log('\nChecking optional files:');
  optionalFiles.forEach(file => {
    const filePath = path.join(__dirname, file);
    const exists = checkFileExists(filePath);
    const status = exists ? '✓' : '○'; // ○ for optional missing files
    console.log(`  ${status} ${file}`);
  });
  
  console.log('\n' + '='.repeat(50));
  if (allRequiredFilesPresent) {
    console.log('✓ All required files are present!');
    console.log('\nImportant: This is a template/boilerplate for the mobile app.');
    console.log('To run the app, you need to properly initialize a React Native project.');
    console.log('\nNext steps:');
    console.log('1. Run the setup script:');
    console.log('   - Windows: setup-project.bat');
    console.log('   - macOS/Linux: ./setup-project.sh');
    console.log('   - Or run: node setup-project.js');
    console.log('\n2. Follow the instructions in SETUP.md for manual setup');
  } else {
    console.log('✗ Some required files are missing. Please check the setup.');
  }
  console.log('='.repeat(50));
}

// Run verification if this file is executed directly
if (require.main === module) {
  verifySetup();
}

module.exports = { verifySetup };