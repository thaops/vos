import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/login/data/datasources/local/login_local_datasource.dart';
import 'package:vos_flutter/feature/login/data/datasources/remote/google_sign_in_adapter.dart';
import 'package:vos_flutter/feature/login/data/datasources/remote/login_remote_datasource.dart';
import 'package:vos_flutter/feature/login/data/repository_impl/login_repository_impl.dart';
import 'package:vos_flutter/feature/login/domain/repositories/login_repository.dart';
import 'package:vos_flutter/feature/login/domain/usecases/check_auth_state_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_out_usecase.dart';
import 'package:vos_flutter/feature/login/presentation/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    final macDesktopClientId = dotenv.env['MACOS_GOOGLE_DESKTOP_CLIENT_ID'];

    final googleAdapter = createGoogleAdapter(
      macDesktopClientId: Platform.isMacOS ? macDesktopClientId : null,
    );

    // 2. Data Sources (Remote & Local)
    Get.lazyPut<LoginRemoteDataSource>(
      () => LoginRemoteDataSourceImpl(googleAdapter: googleAdapter),
    );

    Get.lazyPut<LoginLocalDataSource>(() => LoginLocalDataSourceImpl());

    // 3. Repository
    Get.lazyPut<LoginRepository>(
      () => LoginRepositoryImpl(
        remoteDataSource: Get.find<LoginRemoteDataSource>(),
        localDataSource: Get.find<LoginLocalDataSource>(),
      ),
    );

    // 4. Use Cases
    Get.lazyPut<SignInWithGoogleUsecase>(
      () =>
          SignInWithGoogleUsecase(loginRepository: Get.find<LoginRepository>()),
    );

    Get.lazyPut<CheckAuthStateUsecase>(
      () => CheckAuthStateUsecase(loginRepository: Get.find<LoginRepository>()),
    );

    Get.lazyPut<SignOutUsecase>(
      () => SignOutUsecase(loginRepository: Get.find<LoginRepository>()),
    );

    // 5. Controller (phụ thuộc vào Use Cases)
    Get.lazyPut<LoginController>(
      () => LoginController(
        signInWithGoogleUseCase: Get.find<SignInWithGoogleUsecase>(),
        checkAuthStateUseCase: Get.find<CheckAuthStateUsecase>(),
        signOutUseCase: Get.find<SignOutUsecase>(),
      ),
    );
  }
}
