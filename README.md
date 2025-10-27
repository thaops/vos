# VOS Flutter App

Ứng dụng Flutter cho hệ thống VOS (Voice of Staff).

## Mô tả

Đây là ứng dụng mobile được phát triển bằng Flutter framework, cung cấp các tính năng quản lý và tương tác cho hệ thống VOS.

## Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng cross-platform
- **Dart**: Ngôn ngữ lập trình chính
- **Firebase**: Backend services
- **Material Design**: UI/UX design system

## Cài đặt và chạy

### Yêu cầu hệ thống

- Flutter SDK (phiên bản 3.0 trở lên)
- Dart SDK
- Android Studio hoặc VS Code
- Android SDK (cho Android)
- Xcode (cho iOS)

### Các bước cài đặt

1. Clone repository:
```bash
git clone https://github.com/thaops/vos.git
cd vos
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## Cấu trúc project

```
lib/
├── common/          # Các widget và utility chung
├── controllers/     # Business logic controllers
├── core/           # Core functionality
├── feature/        # Các tính năng chính của app
├── router/         # Navigation routing
└── main.dart       # Entry point
```

## Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng tạo pull request hoặc issue để thảo luận về các thay đổi.

## License

Dự án này được phát hành dưới giấy phép MIT.
