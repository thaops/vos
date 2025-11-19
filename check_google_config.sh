#!/bin/bash

echo "🔍 Checking Google Sign In Configuration"
echo "========================================"
echo ""

# Check Info.plist
echo "1. Checking Info.plist for GIDClientID..."
if grep -q "GIDClientID" ios/Runner/Info.plist; then
    echo "   ✅ GIDClientID found in Info.plist"
    grep "GIDClientID" -A 1 ios/Runner/Info.plist | head -2
else
    echo "   ❌ GIDClientID NOT found in Info.plist"
fi

echo ""

# Check URL Scheme
echo "2. Checking URL Scheme..."
if grep -q "REVERSED_CLIENT_ID" ios/Runner/Info.plist || grep -q "com.googleusercontent.apps" ios/Runner/Info.plist; then
    echo "   ✅ URL Scheme found in Info.plist"
    grep -A 3 "CFBundleURLSchemes" ios/Runner/Info.plist | head -4
else
    echo "   ❌ URL Scheme NOT found in Info.plist"
fi

echo ""

# Check GoogleService-Info.plist
echo "3. Checking GoogleService-Info.plist..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "   ✅ GoogleService-Info.plist exists"
    
    # Check CLIENT_ID
    if grep -q "CLIENT_ID" ios/Runner/GoogleService-Info.plist; then
        CLIENT_ID=$(grep -A 1 "CLIENT_ID" ios/Runner/GoogleService-Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
        echo "   ✅ CLIENT_ID: $CLIENT_ID"
    fi
else
    echo "   ❌ GoogleService-Info.plist NOT found"
fi

echo ""

# Check if file is in Xcode project (basic check)
echo "4. Checking if GoogleService-Info.plist is in Xcode project..."
if grep -q "GoogleService-Info.plist" ios/Runner.xcodeproj/project.pbxproj 2>/dev/null; then
    echo "   ✅ GoogleService-Info.plist found in Xcode project"
else
    echo "   ⚠️  GoogleService-Info.plist may not be in Xcode project"
    echo "   → Open Xcode and ensure it's added to 'Copy Bundle Resources'"
fi

echo ""
echo "========================================"
echo "✅ Configuration check complete!"
echo ""
echo "Next steps:"
echo "1. Rebuild app: flutter clean && flutter pub get"
echo "2. Run: flutter run"
echo "3. If still issues, open Xcode and check:"
echo "   - GoogleService-Info.plist is in project"
echo "   - File is in 'Copy Bundle Resources' phase"

