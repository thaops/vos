import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:vos_flutter/firebase_options.dart';
import 'package:vos_flutter/feature/login/presentation/controller/login_controller.dart';
import 'package:vos_flutter/feature/login/data/datasources/remote/login_remote_datasource.dart';
import 'package:vos_flutter/feature/login/data/datasources/local/login_local_datasource.dart';
import 'package:vos_flutter/feature/login/data/repository_impl/login_repository_impl.dart';
import 'package:vos_flutter/feature/login/domain/repositories/login_repository.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/check_auth_state_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_out_usecase.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Tạo GoogleSignIn instance
    final googleSignIn = Platform.isIOS
        ? GoogleSignIn(
            scopes: ['email', 'profile'],
            serverClientId: DefaultFirebaseOptions.ios.iosClientId,
          )
        : GoogleSignIn(scopes: ['email', 'profile']);

    // 2. Data Sources (Remote & Local)
    Get.lazyPut<LoginRemoteDataSource>(
      () => LoginRemoteDataSourceImpl(googleSignIn: googleSignIn),
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
