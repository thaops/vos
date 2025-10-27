import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/models/login_request.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/models/login_response.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/services/auth_service.dart';

class LoginController extends GetxController {
  final GetStorage _storage = GetStorage();
  final AuthService _authService = AuthService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  RxInt tapCount = 0.obs;

  // Reactive variables for modern login
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool showPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setDefaultCredentials();
    _loadSavedCredentials();
  }

  void _setDefaultCredentials() {
    // Set cứng username và password mặc định
    usernameController.text = 'NamPhuong';
    passwordController.text = 'NamPhuong@1234';
  }

  void _loadSavedCredentials() {
    if (_storage.read('remember_me') == true) {
      rememberMe.value = true;
      usernameController.text = _storage.read('saved_username') ?? 'NamPhuong';
      passwordController.text =
          _storage.read('saved_password') ?? 'NamPhuong@1234';
    }
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> loginFramework(BuildContext context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Create login request
      final loginRequest = LoginRequest(
        userCode: usernameController.text.trim(),
        password: passwordController.text,
      );

      // Call API
      final response = await _authService.login(loginRequest);

      if (response.isSuccess && response.data != null) {
        // Save credentials if remember me is checked
        if (rememberMe.value) {
          await _storage.write('remember_me', true);
          await _storage.write('saved_username', usernameController.text);
          await _storage.write('saved_password', passwordController.text);
        } else {
          await _storage.remove('remember_me');
          await _storage.remove('saved_username');
          await _storage.remove('saved_password');
        }

        // Save login state and user data
        await _storage.write('is_logged_in', true);
        await _storage.write('user_id', response.data!.userId);
        await _storage.write('user_code', response.data!.userCode);
        await _storage.write('user_name', response.data!.userName);
        await _storage.write('user_token', response.data!.token);
        await _storage.write('company_id', response.data!.companyId);
        await _storage.write('company_name', response.data!.companyNameVN);
        await _storage.write('token_expired', response.data!.tokenExpired);

        // Save complete user profile data
        await _storage.write('user_profile_data', response.data!.toJson());

        Get.snackbar(
          'Thành công',
          'Đăng nhập thành công! Chào mừng ${response.data!.userName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );

        // Navigate to main screen
        Get.offAllNamed(AppRouter.main);
      } else {
        Get.snackbar(
          'Lỗi',
          response.message.isNotEmpty ? response.message : 'Đăng nhập thất bại',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          icon: const Icon(Icons.error_outline, color: Colors.red),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showConfigDialog() {
    if (tapCount.value >= 5) {
      tapCount.value = 0;
      // TODO: Implement config dialog
      Get.snackbar(
        'Config',
        'Config dialog feature coming soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
