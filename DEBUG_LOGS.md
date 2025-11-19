# Hướng dẫn xem log khi app crash

## 1. Chạy app với verbose logging

### Trên Terminal:
```bash
# Chạy với verbose logging
flutter run --verbose

# Hoặc với device logs
flutter run --verbose 2>&1 | tee app_log.txt
```

### Trên iOS Simulator/Device:
```bash
# Xem device logs trong real-time
xcrun simctl spawn booted log stream --level=debug --predicate 'processImagePath contains "vos"'

# Hoặc cho physical device
idevicesyslog -u <device-udid>
```

## 2. Xem log file trong app

Log file được lưu tại:
- **iOS Simulator**: `~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/logs/`
- **iOS Device**: Cần dùng Xcode để xem (Window > Devices and Simulators > Select device > View Device Logs)

### Cách xem log file từ code:
```dart
import 'package:vos_flutter/common/utils/file_logger.dart';

// Đọc log
final logs = await FileLogger.readLogs();
print(logs);

// Lấy đường dẫn file
final path = FileLogger.getLogFilePath();
print('Log file: $path');
```

## 3. Xem log trong Xcode

1. Mở Xcode
2. Window > Devices and Simulators
3. Chọn device/simulator
4. Click "Open Console" hoặc "View Device Logs"
5. Filter theo tên app: "vos" hoặc "VOS Viags"

## 4. Xem log từ Terminal (macOS)

```bash
# Xem log của iOS Simulator
xcrun simctl spawn booted log stream --level=debug --predicate 'processImagePath contains "vos"'

# Xem crash logs
xcrun simctl spawn booted log show --predicate 'processImagePath contains "vos"' --last 5m
```

## 5. Kiểm tra crash logs trên device

### iOS:
```bash
# List crash logs
ls ~/Library/Logs/DiagnosticReports/

# Hoặc
ls ~/Library/Logs/CrashReporter/
```

### Android:
```bash
# Xem logcat
adb logcat | grep -i vos

# Xem crash logs
adb logcat *:E | grep -i vos
```

## 6. Debug với breakpoints

1. Mở Xcode
2. Attach to process: Product > Attach to Process > Chọn app
3. Set breakpoints tại các điểm quan trọng
4. Chạy app và xem call stack khi crash

## 7. Sử dụng Instruments (iOS)

1. Xcode > Product > Profile
2. Chọn "Leaks" hoặc "Allocations"
3. Reproduce crash và xem memory issues

## 8. Kiểm tra log file trong app

Thêm button debug để xem log:
```dart
// Trong login screen hoặc debug menu
ElevatedButton(
  onPressed: () async {
    final logs = await FileLogger.readLogs();
    print('=== APP LOGS ===');
    print(logs);
    Get.snackbar('Logs', 'Check console for logs');
  },
  child: Text('View Logs'),
)
```

## Lưu ý

- Log file được tự động rotate (giữ 5 file gần nhất)
- Log file có thể lớn, nên clean định kỳ
- Trên production, nên disable file logging hoặc chỉ log errors

