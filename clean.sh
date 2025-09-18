#!/bin/bash

echo "🧹 Cleaning Flutter project..."

# Hapus build folders
rm -rf build/
rm -rf android/app/build/
rm -rf ios/build/
rm -rf .dart_tool/

# Hapus cache files
rm -f .packages
rm -f .flutter-plugins
rm -f pubspec.lock

# Clean Android
cd android && ./gradlew clean && cd ..

# Clean iOS
cd ios && pod cache clean --all && rm -rf Pods/ Podfile.lock && cd ..

# Flutter clean
flutter clean

# Get packages kembali
flutter pub get

echo "✅ Project cleaned successfully!"