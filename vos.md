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