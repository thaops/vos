import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/check_auth_state_usecase.dart';
import 'package:vos_flutter/feature/login/domain/usecases/sign_out_usecase.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';

class LoginController extends BaseController with ApiResultMixin {
  final SignInWithGoogleUsecase signInWithGoogleUseCase;
  final CheckAuthStateUsecase checkAuthStateUseCase;
  final SignOutUsecase signOutUseCase;
  final GetStorage _storage = GetStorage();

  LoginController({
    required this.signInWithGoogleUseCase,
    required this.checkAuthStateUseCase,
    required this.signOutUseCase,
  });

  User? currentUser;
  RxInt tapCount = 0.obs;
  bool _isSigningIn = false;

  bool get isEmployee => _storage.read<bool>('is_employee') ?? false;

  void setEmployeeStatus(bool isEmployee) {
    _storage.write('is_employee', isEmployee);
  }

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
        
        final storage = GetStorage();
        if (!storage.hasData('is_employee')) {
          _showEmployeeDialog();
        } else {
          Get.offAllNamed(AppRouter.main);
        }
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
          
          if (!_storage.hasData('is_employee')) {
            _showEmployeeDialog();
          } else {
            Get.offAllNamed(AppRouter.main);
          }
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

  Future<void> _showEmployeeDialog() async {
    try {
      if (Get.isDialogOpen == true) {
        return;
      }

      await Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Không cho phép đóng bằng back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Xác nhận',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Bạn có phải nhân viên không?',
              style: TextStyle(fontSize: 16.sp),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setEmployeeStatus(false);
                  Get.back();
                  Get.offAllNamed(AppRouter.main);
                },
                child: Text(
                  'Không',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setEmployeeStatus(true);
                  Get.back();
                  Get.offAllNamed(AppRouter.main);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Có',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      // Ignore errors
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