import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/controllers/base/base_controller.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/models/google_user_model.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/firebase_options.dart';
import 'package:vos_flutter/common/utils/file_logger.dart';

class LoginController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();
  RxInt tapCount = 0.obs;

  // Single instance of GoogleSignIn to prevent concurrent operations
  late final GoogleSignIn _googleSignIn = Platform.isIOS
      ? GoogleSignIn(
          scopes: ['email', 'profile'],
          // Cần cả clientId và serverClientId trên iOS
          // clientId: OAuth client ID từ GoogleService-Info.plist
          // serverClientId: Để lấy idToken cho Firebase
          serverClientId: DefaultFirebaseOptions.ios.iosClientId,
        )
      : GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  // Flag to prevent concurrent sign-in calls
  bool _isSigningIn = false;

  /// Kiểm tra xem user có phải nhân viên không
  bool get isEmployee => _storage.read<bool>('is_employee') ?? false;

  /// Lưu trạng thái nhân viên
  void setEmployeeStatus(bool isEmployee) {
    _storage.write('is_employee', isEmployee);
  }

  @override
  void onInit() {
    super.onInit();
    // Chỉ check Google auth nếu đang ở login screen
    // Nếu đã vào từ splash với Google auth thì không cần check lại
    // (tránh delay và flash login screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay nhỏ để đảm bảo navigation đã hoàn tất
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.currentRoute == AppRouter.login) {
          checkGoogleAuthState();
        }
      });
    });
  }

  /// Check if user already has valid Google token and auto login
  Future<void> checkGoogleAuthState() async {
    try {
      // Đảm bảo Hive box đã được mở
      if (!Hive.isBoxOpen('google_user_box')) {
        await Hive.openBox('google_user_box');
      }
      final box = Hive.box('google_user_box');
      final userData = box.get('current_user');

      if (userData != null) {
        final googleUser = GoogleUserModel.fromJson(
          Map<String, dynamic>.from(userData),
        );

        // Check if Firebase Auth still has valid session
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == googleUser.uid) {
          // User is still logged in, try to refresh token and navigate
          try {
            final idToken = await currentUser.getIdToken(true);
            // Token refreshed successfully, update Hive and navigate
            final updatedUser = GoogleUserModel.fromFirebaseUser(
              uid: currentUser.uid,
              displayName: currentUser.displayName,
              email: currentUser.email,
              photoURL: currentUser.photoURL,
              idToken: idToken,
            );
            await box.put('current_user', updatedUser.toJson());

            // Kiểm tra nếu chưa có trạng thái nhân viên thì hiển thị dialog
            final storage = GetStorage();
            if (!storage.hasData('is_employee')) {
              await _showEmployeeDialog();
            }

            Get.offAllNamed(AppRouter.main);
          } catch (e) {
            // Token expired or invalid, clear and stay on login
            await box.delete('current_user');
            await _auth.signOut();
          }
        } else {
          // No current user or UID mismatch, clear and stay on login
          await box.delete('current_user');
          if (currentUser != null) {
            await _auth.signOut();
          }
        }
      }
    } catch (e) {
      // Error reading from Hive, clear and stay on login
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }

  Future<void> signInWithGoogle() async {
    // Prevent concurrent calls
    if (_isSigningIn || isLoading) {
      return;
    }

    try {
      _isSigningIn = true;
      setStatus(ControllerStatus.loading);
      await FileLogger.log('Starting Google Sign In...');

      // Trigger the authentication flow
      await FileLogger.log('Calling _googleSignIn.signIn()...');
      await FileLogger.log('GoogleSignIn config - serverClientId: ${_googleSignIn.serverClientId}');
      
      // Thêm timeout để tránh hang và có thể catch native crash
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Google Sign In timeout after 30 seconds');
            },
          );
      
      await FileLogger.log('Google Sign In response received: ${googleUser != null ? "Success" : "Cancelled"}');

      if (googleUser == null) {
        // User canceled the sign-in
        setStatus(ControllerStatus.initial);
        _isSigningIn = false;
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Kiểm tra idToken - cần thiết cho Firebase Auth
      if (googleAuth.idToken == null) {
        throw Exception('Không thể lấy idToken từ Google Sign In. Vui lòng thử lại.');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        // Get Firebase token
        final idToken = await user.getIdToken();

        // Create GoogleUserModel
        final googleUserModel = GoogleUserModel.fromFirebaseUser(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoURL: user.photoURL,
          idToken: idToken,
        );

        // Save to Hive as JSON - đảm bảo box đã mở
        if (!Hive.isBoxOpen('google_user_box')) {
          await Hive.openBox('google_user_box');
        }
        final box = Hive.box('google_user_box');
        await box.put('current_user', googleUserModel.toJson());

        setStatus(ControllerStatus.success);

        // Refresh ProfileController if it exists
        try {
          if (Get.isRegistered<ProfileController>()) {
            final profileController = Get.find<ProfileController>();
            profileController.refreshGoogleUser();
          }
        } catch (e) {
          print('ProfileController not registered yet: $e');
        }

        // Hiển thị dialog hỏi "Bạn có phải nhân viên không?"
        // Chỉ hiển thị nếu chưa có giá trị lưu trữ
        try {
          if (!_storage.hasData('is_employee')) {
            await _showEmployeeDialog();
          }
        } catch (e) {
          print('⚠️ Error showing employee dialog: $e');
          // Tiếp tục navigation dù dialog có lỗi
        }

        // Navigate to main screen - wrap trong try-catch
        try {
          await Get.offAllNamed(AppRouter.main);
        } catch (e) {
          print('❌ Error navigating to main: $e');
          // Thử lại với delay nhỏ
          await Future.delayed(const Duration(milliseconds: 300));
          await Get.offAllNamed(AppRouter.main);
        }
      }
    } catch (e, stackTrace) {
      // Ghi vào file log
      await FileLogger.logError(
        e,
        stackTrace,
        context: 'signInWithGoogle',
      );
      
      // Log chi tiết lỗi để debug
      print('❌ Error in signInWithGoogle: $e');
      print('Stack trace: $stackTrace');
      print('📄 Log file: ${FileLogger.getLogFilePath()}');
      
      setStatus(
        ControllerStatus.error, 
        error: 'Đăng nhập thất bại: ${e.toString()}',
      );
      
      // Hiển thị thông báo lỗi cho user
      Get.snackbar(
        'Lỗi đăng nhập',
        'Không thể đăng nhập bằng Google. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isSigningIn = false;
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

  /// Hiển thị dialog hỏi "Bạn có phải nhân viên không?"
  Future<void> _showEmployeeDialog() async {
    try {
      // Kiểm tra xem đã có dialog đang mở chưa
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
      print('⚠️ Error showing employee dialog: $e');
      // Không throw error để tránh crash
    }
  }
}
