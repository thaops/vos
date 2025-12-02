import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/check_auth_state_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_out_usecase.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class LoginController extends BaseController with ApiResultMixin {
  final SignInWithGoogleUsecase signInWithGoogleUseCase;
  final CheckAuthStateUsecase checkAuthStateUseCase;
  final SignOutUsecase signOutUseCase;

  LoginController({
    required this.signInWithGoogleUseCase,
    required this.checkAuthStateUseCase,
    required this.signOutUseCase,
  });

  User? currentUser;
  RxInt tapCount = 0.obs;
  bool _isSigningIn = false;


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.currentRoute == AppRouter.login) {
          checkGoogleAuthState();
        }
      });
    });
  }

  /// Check Google Auth State - sử dụng Use Case
  Future<void> checkGoogleAuthState() async {
    await handleApiCall<User>(
      apiCall: () => checkAuthStateUseCase.call(),
      showErrorSnackbar: false, // Không hiển thị lỗi khi check auth
      onSuccess: (user) {
        currentUser = user;
        // Refresh ProfileController nếu có
        _refreshProfileController();
        
        // ✅ Set flag để MainScreen mở tab Tin tức sau khi login
        GetStorage().write('shouldOpenNewsTab', true);
        
        // Tự động navigate về main, không cần hỏi nhân viên nữa
        Get.offAllNamed(AppRouter.main);
      },
    );
  }

  /// Sign in với Google - sử dụng Use Case
  Future<void> signInWithGoogle() async {
    if (_isSigningIn || isLoading) return;

    try {
      _isSigningIn = true;
      await handleApiCall<User>(
        apiCall: () => signInWithGoogleUseCase.call(),
        onSuccess: (user) {
          currentUser = user;
          // Refresh ProfileController nếu có
          _refreshProfileController();
          
          // ✅ Set flag để MainScreen mở tab Tin tức sau khi login
          GetStorage().write('shouldOpenNewsTab', true);
          
          // Tự động navigate về main, không cần hỏi nhân viên nữa
          Get.offAllNamed(AppRouter.main);
        },
      );
    } finally {
      _isSigningIn = false;
    }
  }

  /// Refresh ProfileController nếu đã được register
  void _refreshProfileController() {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.refreshGoogleUser();
      }
    } catch (e) {
      // ProfileController chưa được tạo, không sao
    }
  }


  void showConfigDialog() {
    if (tapCount.value >= 5) {
      tapCount.value = 0;
      Get.snackbar(
        'Config',
        'Config dialog feature coming soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}