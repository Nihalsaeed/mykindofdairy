/**
 * Script to help set up the React Native project properly
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

function setupProject() {
  console.log('My Kind of Dairy Mobile App Setup Script');
  console.log('========================================\n');
  
  try {
    // Check if we're in the right directory
    const currentDir = process.cwd();
    const dirName = path.basename(currentDir);
    
    if (dirName !== 'mobile-app') {
      console.log('⚠️  Please run this script from the mobile-app directory');
      return;
    }
    
    // Go to parent directory
    const parentDir = path.join(currentDir, '..');
    process.chdir(parentDir);
    console.log(`\n📁 Changed to parent directory: ${parentDir}`);
    
    // Check if MyKindOfDairyMobile already exists
    const projectDir = path.join(parentDir, 'MyKindOfDairyMobile');
    if (fs.existsSync(projectDir)) {
      console.log('⚠️  MyKindOfDairyMobile directory already exists');
      console.log('   Please remove it or choose a different location');
      return;
    }
    
    console.log('\n🔧 Creating React Native project using the recommended approach...');
    console.log('   This may take several minutes...\n');
    
    // Create the React Native project using the recommended approach
    execSync('npx @react-native-community/cli init MyKindOfDairyMobile', { stdio: 'inherit' });
    
    console.log('\n✅ React Native project created successfully!');
    
    // Change to the new project directory
    process.chdir(projectDir);
    console.log(`\n📁 Changed to project directory: ${projectDir}`);
    
    console.log('\n📦 Installing required dependencies...');
    const dependencies = [
      'react-native-fs',
      'react-native-document-picker',
      '@react-navigation/native',
      '@react-navigation/stack',
      'react-native-screens',
      'react-native-safe-area-context',
      'react-native-gesture-handler'
    ];
    
    execSync(`npm install ${dependencies.join(' ')}`, { stdio: 'inherit' });
    
    console.log('\n✅ Dependencies installed successfully!');
    
    // Copy the App.js file from the template and remove App.tsx
    console.log('\n📋 Copying App.js from template and removing default App.tsx...');
    const templateAppJs = path.join(parentDir, 'mobile-app', 'App.js');
    const projectAppJs = path.join(projectDir, 'App.js');
    const projectAppTsx = path.join(projectDir, 'App.tsx');
    
    // Remove the default App.tsx
    if (fs.existsSync(projectAppTsx)) {
      fs.unlinkSync(projectAppTsx);
      console.log('✅ Removed default App.tsx');
    }
    
    // Copy our App.js
    fs.copyFileSync(templateAppJs, projectAppJs);
    console.log('✅ App.js copied successfully!');
    
    // Update package.json to use App.js instead of App.tsx
    const packageJsonPath = path.join(projectDir, 'package.json');
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    packageJson.main = 'index.js'; // Make sure this is correct
    fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));
    console.log('✅ Updated package.json');
    
    console.log('\n📋 Next steps:');
    console.log('1. For iOS: cd ios && pod install');
    console.log('2. For Android: Make sure an emulator is running or device is connected');
    console.log('3. Run the app:');
    console.log('   - Android: npx react-native run-android');
    console.log('   - iOS: npx react-native run-ios');
    
    console.log('\n🎉 Setup complete! Your React Native project is ready to use.');
    
  } catch (error) {
    console.error('\n❌ An error occurred during setup:');
    console.error(error.message);
    console.log('\nPlease check the error message above and try again.');
    console.log('You may need to manually follow the setup instructions in SETUP.md');
  }
}

// Run setup if this file is executed directly
if (require.main === module) {
  setupProject();
}

module.exports = { setupProject };