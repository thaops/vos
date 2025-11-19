#!/bin/bash

echo "🚀 Building VOS Viags app with correct name and bundle ID..."

# Stop the app if running
echo "🛑 Stopping Flutter app..."
pkill -f "VOS" || true

# Clean build
echo "🧹 Cleaning Flutter build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Clean all builds
echo "🧹 Cleaning all builds..."
rm -rf ios/build/
rm -rf macos/build/
rm -rf android/build/
rm -rf build/

# Build for all platforms
echo "🔨 Building VOS Viags app..."

# Build iOS
echo "📱 Building iOS..."
flutter build ios --debug

# Build macOS
echo "💻 Building macOS..."
flutter build macos --debug

# Build Android
echo "🤖 Building Android..."
flutter build apk --debug

echo "✅ VOS Viags app built successfully!"
echo ""
echo "📋 App details:"
echo "   - Name: VOS Viags"
echo "   - Bundle ID: vn.viags.vos"
echo "   - Icon: icon_app.png"
echo ""
echo "📱 iOS:"
echo "   - Location: build/ios/Debug-iphoneos/Runner.app"
echo "   - Display Name: VOS Viags"
echo ""
echo "💻 macOS:"
echo "   - Location: build/macos/Build/Products/Debug/VOS Viags.app"
echo "   - Display Name: VOS Viags"
echo ""
echo "🤖 Android:"
echo "   - Location: build/app/outputs/flutter-apk/app-debug.apk"
echo "   - Display Name: VOS Viags"
echo "   - Package: vn.viags.vos"
echo ""
echo "🚀 To run the app:"
echo "   flutter run -d ios"
echo "   flutter run -d macos"
echo "   flutter run -d android"
