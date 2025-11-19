# Debug Native Crash với Google Sign In

## Vấn đề hiện tại

App crash ngay sau khi gọi `_googleSignIn.signIn()` - đây là **native crash** (iOS native code), không phải Dart exception.

Log cho thấy:
```
[INFO] Calling _googleSignIn.signIn()...
Service protocol connection closed.
Lost connection to device.
```

## Nguyên nhân có thể

### 1. GoogleService-Info.plist không được load
- File phải có trong Xcode project
- Phải được thêm vào "Copy Bundle Resources"

### 2. URL Scheme chưa được register đúng
- Đã thêm vào Info.plist ✓
- Nhưng có thể cần rebuild Xcode project

### 3. Google Sign In plugin chưa được initialize
- Plugin được register qua GeneratedPluginRegistrant
- Nhưng có thể cần configure thêm trong AppDelegate

## Cách debug

### Bước 1: Kiểm tra GoogleService-Info.plist trong Xcode

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Kiểm tra `GoogleService-Info.plist` có trong project:
   - Click vào file trong Project Navigator
   - Xem "Target Membership" - phải có checkmark cho "Runner"
3. Kiểm tra "Copy Bundle Resources":
   - Select target "Runner"
   - Build Phases > Copy Bundle Resources
   - Đảm bảo `GoogleService-Info.plist` có trong list

### Bước 2: Xem crash log trong Xcode

1. Mở Xcode
2. Window > Devices and Simulators
3. Chọn device/simulator
4. Click "View Device Logs"
5. Tìm crash log gần nhất (sẽ có tên app và timestamp)
6. Click vào để xem chi tiết

### Bước 3: Xem console log trong Xcode

1. Mở Xcode
2. Product > Scheme > Edit Scheme
3. Run > Arguments
4. Thêm Environment Variables:
   - `OS_ACTIVITY_MODE` = `disable` (để giảm noise)
5. Chạy app từ Xcode (không phải `flutter run`)
6. Xem console output khi click đăng nhập Google

### Bước 4: Kiểm tra crash log từ Terminal

```bash
# Xem crash logs gần nhất
xcrun simctl spawn booted log show --predicate 'processImagePath contains "vos"' --last 5m --style syslog | grep -i "error\|crash\|exception" -A 10

# Hoặc xem tất cả logs
xcrun simctl spawn booted log show --predicate 'processImagePath contains "vos"' --last 5m
```

### Bước 5: Rebuild từ Xcode

1. Clean build folder: Product > Clean Build Folder (Shift + Cmd + K)
2. Xóa DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Rebuild:
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```
4. Mở Xcode và build lại: Product > Build (Cmd + B)

## Giải pháp thử

### 1. Đảm bảo GoogleService-Info.plist được copy

Trong Xcode:
- Select `GoogleService-Info.plist`
- File Inspector > Target Membership
- Đảm bảo "Runner" được check

### 2. Kiểm tra Bundle ID

Trong Xcode:
- Select target "Runner"
- General > Bundle Identifier
- Phải khớp với `BUNDLE_ID` trong `GoogleService-Info.plist`: `vn.viags.vos`

### 3. Rebuild hoàn toàn

```bash
# Clean everything
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod deintegrate
pod install
cd ..
flutter clean
rm -rf build
flutter pub get

# Rebuild
flutter build ios --debug --no-codesign
```

### 4. Chạy từ Xcode thay vì Flutter CLI

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Select scheme: "Runner" > "iPhone Simulator"
3. Product > Run (Cmd + R)
4. Xem console output trong Xcode

## Kiểm tra log file

Log file được lưu tại:
```
/Users/thao/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/logs/
```

Xem log:
```bash
cat "/path/to/log/file.txt"
```

## Next Steps

1. Chạy app từ Xcode và xem console
2. Kiểm tra crash log trong Xcode
3. Đảm bảo GoogleService-Info.plist được copy vào bundle
4. Rebuild hoàn toàn nếu cần

