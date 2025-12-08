lib/feature/
├── login/
│   ├── data/                    ✅ Data layer
│   │   ├── models/              ✅ DTOs (Data Transfer Objects)
│   │   │   ├── login_request_dto.dart
│   │   │   ├── login_response_dto.dart
│   │   │   └── google_user_dto.dart
│   │   ├── datasources/         ✅ Data sources
│   │   │   ├── remote/
│   │   │   │   └── login_remote_datasource.dart
│   │   │   └── local/
│   │   │       └── login_local_datasource.dart
│   │   └── repository_impl/     ✅ Repository implementations
│   │       └── login_repository_impl.dart
│   ├── domain/                  ✅ Domain layer (business logic)
│   │   ├── models/              ✅ Domain entities
│   │   │   ├── user.dart
│   │   │   └── auth_token.dart
│   │   ├── repositories/        ✅ Repository interfaces
│   │   │   └── login_repository.dart
│   │   └── usecases/            ✅ Use cases
│   │       ├── sign_in_usecase.dart
│   │       ├── sign_in_with_google_usecase.dart
│   │       └── check_auth_state_usecase.dart
│   ├── presentation/            ✅ Presentation layer (UI)
│   │   ├── controller/
│   │   │   └── login_controller.dart
│   │   ├── view/
│   │   │   └── login_screen.dart
│   │   └── widgets/
│   │       └── login_card_widget.dart
│   └── binding/
│       └── login_binding.dart

# Chỉ cần chạy:
mfeature news

# Script sẽ hỏi:
# - Usecases (có thể Enter để skip)
# - Has local storage? [Y]
# - Has remote API? [Y]  
# - Has pagination? [N]
# - Has search? [N]
# - Has full cache? [N]
# - API base path [/api/news]
dfeature news ->delete 

NewsController.getNews() -> bắt đầu sự kiện load news hiên thị state loading error success 
  → GetNewsUsecase.call() -> Tầng domain chưa logic nghiệm vụ không chứa api hay store  để gọi repository mục đính quy định hành động của app như nhận data tin tức
    → NewsRepository.getNews() -> cầu nối giữa domain và data layer  nhận mà không cần biết data remote hay local trả về 
      → NewsRepositoryImpl.getNews() -> tầng newrepositoryImpl -> tần logic nơi quyết định lấy data từ đâu remote || local 
        → NewsRemoteDataSource.getNews() -> tầng remotesoure-> tầngg api caller -> chỉ call api http không chưa logic 
          ├─ ✅ Success → Cache vào Local → Trả về
          └─ ❌ Error → Fallback Local
              → NewsLocalDataSource.getNewsPage() -> lưu đọc data base 
                ├─ ✅ Có data → Trả về từ cache
                └─ ❌ Không có → Trả về error từ Remote

                V0S@2025!
                storePassword=V0S@2025!
                VOS@2025!
keyPassword=V0S@2025!
keyAlias=vos-upload
storeFile=C:\\Flutter-dev\\vos_flutter\\android\\vos-upload-keystore.jks