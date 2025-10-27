# OTA Update với Shorebird SDK

## 🧩 Luồng hoạt động

### 1️⃣ Mở app lần đầu
- Hiển thị splash screen với logo TCS (1-2 giây)
- Trong nền: gọi `shorebird.downloadUpdateIfAvailable()`
- Nếu có patch → SDK tải về, apply tự động (hiệu lực lần mở sau)
- Nếu không có patch → vào app bình thường

### 2️⃣ Lần mở tiếp theo
- Patch đã được apply → code luôn mới nhất
- Không cần restart app thủ công

## 📁 Files đã tạo

### Core Services
- `lib/common/services/ota_update_service.dart` - Service chính handle OTA
- `lib/controllers/splash_controller.dart` - Controller quản lý splash flow

### UI Components  
- `lib/common/widgets/splash_screen_widget.dart` - Splash screen đẹp với animation
- `lib/common/widgets/ota_update_widget.dart` - Widget hiển thị thông tin update (optional)

### Integration
- `lib/main.dart` - Đã tích hợp splash screen mới

## 🚀 Cách sử dụng

### 1. Splash Screen tự động
```dart
// Đã tích hợp sẵn trong main.dart
// Không cần làm gì thêm
```

### 2. Manual check update (trong settings)
```dart
import 'package:vos_flutter/controllers/splash_controller.dart';

// Trong settings screen
final splashController = Get.find<SplashController>();
await splashController.checkForUpdates();
```

### 3. Hiển thị OTA info widget
```dart
import 'package:vos_flutter/common/widgets/ota_update_widget.dart';

// Trong settings screen
const OTAUpdateWidget()
```

## ⚙️ Configuration

### Shorebird Config
```yaml
# shorebird.yaml
app_id: 35ad0958-a3d6-41a0-91e4-a7ea22c868a1
# auto_update: false  # Uncomment để disable auto update
```

### Dependencies
```yaml
# pubspec.yaml
dependencies:
  shorebird_code_push: ^1.0.0
```

## 🔧 API Methods

### OTAUpdateService
```dart
final otaService = OTAUpdateService();

// Kiểm tra và tải update
bool hasUpdate = await otaService.checkAndDownloadUpdate();

// Lấy patch number hiện tại
String patchNumber = await otaService.getCurrentPatchNumber();

// Kiểm tra có update không (không tải)
bool isAvailable = await otaService.isUpdateAvailable();
```

### SplashController
```dart
final controller = Get.find<SplashController>();

// Manual check update
await controller.checkForUpdates();

// Observable states
controller.loadingText.value        // Text hiển thị
controller.isCheckingUpdate.value   // Đang check update
controller.hasUpdate.value          // Có update mới
controller.currentPatchNumber.value // Patch number hiện tại
```

## 🎯 Benefits

✅ **UX tốt**: Không bị "đơ trắng" khi mở app  
✅ **Auto update**: Tự động check và tải patch  
✅ **Seamless**: Patch apply tự động, không cần restart  
✅ **Visual feedback**: Loading text và animation đẹp  
✅ **Error handling**: Xử lý lỗi gracefully  
✅ **Debug friendly**: Console logs chi tiết  

## 📱 User Experience

1. **Lần đầu mở app**: Splash → Check OTA → Navigate
2. **Có update**: Tải patch trong nền, apply lần sau
3. **Không có update**: Vào app ngay lập tức
4. **Lần mở sau**: Code đã được update, chạy mượt mà

## 🐛 Debug

Enable debug logs:
```dart
// Trong OTAUpdateService
if (kDebugMode) {
  print('🔍 Checking for OTA updates...');
  print('📦 New patch available, downloading...');
  print('✅ Patch downloaded successfully');
}
```

## 📋 Checklist

- [x] Thêm shorebird_code_push dependency
- [x] Tạo OTAUpdateService
- [x] Tạo SplashController với reactive states
- [x] Tạo SplashScreenWidget với animation
- [x] Tích hợp vào main.dart
- [x] Tạo OTAUpdateWidget (optional)
- [x] Fix linter errors
- [x] Test flow hoạt động

## 🚨 Lưu ý quan trọng

1. **Shorebird tự động apply patch** - không cần restart thủ công
2. **Patch chỉ hiệu lực lần mở app tiếp theo**
3. **Cần build với Shorebird CLI** để có patch
4. **Test trên device thật** để verify OTA flow
