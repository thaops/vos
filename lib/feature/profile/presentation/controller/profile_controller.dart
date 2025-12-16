import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/check_employee_status_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/check_viags_status_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/link_viags_account_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/unlink_viags_account_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/logout_usecase.dart';
import 'package:vos_flutter/feature/vacation/domain/usecases/get_vacation_list_usecase.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_personal_vacation_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';

class ProfileController extends GetxController {
  final GetUserProfileUsecase getUserProfileUsecase;
  final LinkViagsAccountUsecase linkViagsAccountUsecase;
  final UnlinkViagsAccountUsecase unlinkViagsAccountUsecase;
  final LogoutUsecase logoutUsecase;
  final CheckViagsStatusUsecase checkViagsStatusUsecase;
  final CheckEmployeeStatusUsecase checkEmployeeStatusUsecase;
  final GetVacationListUsecase? getVacationListUsecase;
  final GetPersonalVacationUsecase? getPersonalVacationUsecase;

  ProfileController({
    required this.getUserProfileUsecase,
    required this.linkViagsAccountUsecase,
    required this.unlinkViagsAccountUsecase,
    required this.logoutUsecase,
    required this.checkViagsStatusUsecase,
    required this.checkEmployeeStatusUsecase,
    this.getVacationListUsecase,
    this.getPersonalVacationUsecase,
  });

  // Reactive variables
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final Rx<GoogleUserDto?> googleUser = Rx<GoogleUserDto?>(null);
  final RxBool isLoading = false.obs;

  // Flag để track logout state - ngăn Obx() rebuild khi đang logout
  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  // Flag để track trạng thái liên kết VIAGS (reactive)
  final RxBool isViagsLinked = false.obs;
  final RxString viagsEmail = ''.obs;

  // Flag để track trạng thái nhân viên (reactive)
  final RxBool isEmployee = false.obs;

  // Error message khi link VIAGS thất bại
  final RxString linkViagsError = ''.obs;

  // Vacation data (phép cá nhân) - cache sau khi link VIAGS thành công
  final RxList<Vacation> vacationList = <Vacation>[].obs;
  final RxDouble phepTon = 0.0.obs; // Tồn phép
  final RxDouble overtimeTon = 0.0.obs; // Tồn OT
  final Rx<PersonalVacation?> personalVacation = Rx<PersonalVacation?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    _loadGoogleUserAsync();
    loadViagsStatus();
    loadEmployeeStatus();
  }

  /// Load user profile từ repository
  Future<void> loadUserProfile() async {
    try {
      final result = await getUserProfileUsecase.call();
      if (result.isSuccess && result.data != null) {
        userProfile.value = result.data;
        // Khi có profile mới, tự động update employee status
        isEmployee.value = true;
        // Load vacation data nếu đã có profile
        await loadVacationData();
      } else {
        userProfile.value = null;
        // Khi không có profile, tự động update employee status
        isEmployee.value = false;
        // Clear vacation data
        vacationList.clear();
        phepTon.value = 0.0;
        overtimeTon.value = 0.0;
      }
    } catch (e) {
      userProfile.value = null;
      isEmployee.value = false;
      // Clear vacation data
      vacationList.clear();
      phepTon.value = 0.0;
      overtimeTon.value = 0.0;
    }
  }

  /// Load trạng thái liên kết VIAGS
  Future<void> loadViagsStatus() async {
    try {
      final status = await checkViagsStatusUsecase.call();
      final isLinked = status['isLinked'] as bool? ?? false;
      isViagsLinked.value = isLinked;

      // ✅ Nếu không có liên kết, đảm bảo email bị xóa
      if (!isLinked) {
        viagsEmail.value = '';
      } else {
        viagsEmail.value = status['email'] as String? ?? '';
      }
    } catch (e) {
      isViagsLinked.value = false;
      viagsEmail.value = '';
    }
  }

  /// Reload trạng thái liên kết VIAGS từ storage (public method để gọi từ bên ngoài)
  void reloadViagsStatus() {
    loadViagsStatus();
  }

  /// Load trạng thái nhân viên
  /// Tự động xác định: có VACS profile = nhân viên, không có = khách
  Future<void> loadEmployeeStatus() async {
    try {
      // Kiểm tra xem có VACS profile hay không
      // Nếu có profile thì là nhân viên, nếu không có thì là khách
      isEmployee.value = userProfile.value != null;
    } catch (e) {
      isEmployee.value = false;
    }
  }

  /// Reload trạng thái nhân viên từ storage (public method để gọi từ bên ngoài)
  void reloadEmployeeStatus() {
    loadEmployeeStatus();
  }

  /// Load Google user async
  Future<void> _loadGoogleUserAsync() async {
    try {
      final box = Hive.box('google_user_box');
      final userData = box.get('current_user');

      if (userData != null) {
        googleUser.value = GoogleUserDto.fromJson(
          Map<String, dynamic>.from(userData),
        );
      } else {
        // Storage đã xóa (sau logout) → clear reactive value
        googleUser.value = null;
      }
    } catch (e) {
      googleUser.value = null;
    }
  }

  /// Refresh Google user from Hive (call after login)
  void refreshGoogleUser() {
    _loadGoogleUserAsync();
  }

  /// Refresh tất cả data (gọi sau khi link/unlink VIAGS hoặc khi cần reload)
  Future<void> refreshAll() async {
    await Future.wait([
      loadUserProfile(),
      loadViagsStatus(),
      loadEmployeeStatus(),
    ]);
  }

  /// Đăng xuất: xóa cache, đăng xuất Google, trở về màn hình login
  /// Lưu ý: KHÔNG thay đổi reactive values để tránh mutate disposed widgets
  Future<void> logout() async {
    try {
      // Set flag để ngăn Obx() rebuild trong home_tab
      _isLoggingOut = true;

      // 1. Sign out Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 2. Sign out Google (disconnect để xóa hoàn toàn)
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.disconnect();

      // 3. Clear Hive (Google user data) - phải clear TRƯỚC để tránh auto-login
      final box = Hive.box('google_user_box');
      await box.delete('current_user');

      // 4. Clear GetStorage thông qua usecase
      await logoutUsecase.call();

      // KHÔNG thay đổi reactive values (isLoading, userProfile, googleUser) ở đây
      // Flag _isLoggingOut sẽ được reset khi controller được dispose hoặc recreate
    } catch (e) {
      print('❌ Logout error: $e');

      // Fallback: vẫn clear data ngay cả khi sign out lỗi
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
        await logoutUsecase.call();
      } catch (_) {
        // Ignore cleanup errors
      }
    } finally {
      // Reset flag sau một delay để đảm bảo navigation đã hoàn tất
      Future.delayed(const Duration(seconds: 2), () {
        _isLoggingOut = false;
      });
    }
  }

  /// Liên kết tài khoản VIAGS - sử dụng usecase
  Future<bool> linkViagsAccount(String name, String password) async {
    try {
      isLoading.value = true;
      linkViagsError.value = ''; // Clear error trước khi thử lại

      final result = await linkViagsAccountUsecase.call(name, password);

      if (result.isSuccess && result.data != null) {
        // Cập nhật userProfile từ response
        userProfile.value = result.data;

        // Reload VIAGS status
        await loadViagsStatus();
        // Employee status sẽ tự động update vì userProfile đã được set
        isEmployee.value = true;

        // Cập nhật email trong GoogleUserModel nếu có email từ userProfile (KHÔNG xóa Google cache)
        if (googleUser.value != null &&
            userProfile.value?.email.isNotEmpty == true) {
          try {
            final box = Hive.box('google_user_box');
            final googleUserData = googleUser.value!.toJson();
            googleUserData['email'] =
                userProfile.value!.email; // Cập nhật email từ VIAGS profile
            await box.put('current_user', googleUserData);
            // Cập nhật reactive value
            googleUser.value = GoogleUserDto.fromJson(googleUserData);
            googleUser.refresh();
          } catch (e) {}
        }

        _resetBannerController();

        // Gọi API vacation và cache data
        await loadVacationData();
        
        // Gọi API PersonalVacation để lấy thông tin phép chi tiết và cache HR_No
        await loadPersonalVacation();

        return true;
      } else {
        // Lưu error message từ server
        final errorMsg = result.error ?? 'Không thể liên kết tài khoản VIAGS';
        linkViagsError.value = errorMsg;
        return false;
      }
    } catch (e) {
      // Lưu error message từ exception
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      linkViagsError.value = errorMsg.isNotEmpty
          ? errorMsg
          : 'Có lỗi xảy ra khi liên kết tài khoản';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset BannerController state khi liên kết tài khoản thành công
  void _resetBannerController() {
    try {
      if (Get.isRegistered<BannerController>()) {
        final bannerController = Get.find<BannerController>();
        // Clear banners cũ và set loading state
        bannerController.banners.clear();
        bannerController.isLoading.value = true;
        bannerController.error.value = '';
      }
    } catch (e) {}
  }

  /// Hủy liên kết tài khoản VIAGS - chỉ xóa profile VACS, giữ lại name và password
  Future<bool> unlinkViagsAccount() async {
    try {
      isLoading.value = true;

      final result = await unlinkViagsAccountUsecase.call();

      if (result.isSuccess) {
        // Xóa userProfile
        userProfile.value = null;

        // ✅ Clear VIAGS status và email ngay lập tức
        isViagsLinked.value = false;
        viagsEmail.value = '';

        // Clear vacation data
        vacationList.clear();
        phepTon.value = 0.0;
        overtimeTon.value = 0.0;

        // Reload VIAGS status để đảm bảo đồng bộ với storage
        await loadViagsStatus();
        // Employee status sẽ tự động update vì userProfile đã được xóa
        isEmployee.value = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String get displayName => userProfile.value?.userName ?? 'Người dùng';
  String get userCode => userProfile.value?.userCode ?? '';
  String get companyName => userProfile.value?.companyNameVN ?? '';
  String get email {
    // Ưu tiên email từ VIAGS nếu đã liên kết
    if (isViagsLinked.value && viagsEmail.value.isNotEmpty) {
      return viagsEmail.value;
    }
    return userProfile.value?.email ?? '';
  }

  String get phone => userProfile.value?.phone ?? '';
  String get status => userProfile.value?.status ?? '';
  String get userType => userProfile.value?.userType ?? '';
  String get description => userProfile.value?.description ?? '';

  /// Load vacation data (phép cá nhân) và cache
  Future<void> loadVacationData() async {
    if (getVacationListUsecase == null) {
      return;
    }

    // Đảm bảo userProfile đã có và có hrId
    final profile = userProfile.value;
    if (profile == null) {
      return;
    }

    // Nếu HR_ID = 0 hoặc null, dùng giá trị mặc định 1752
    final hrId = profile.hrId > 0 ? profile.hrId : 1752;

    try {
      final currentYear = DateTime.now().year;
      final result = await getVacationListUsecase!.call(
        year: currentYear,
        hrId: hrId,
        viewData: '',
      );

      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        // Cache vacation list
        vacationList.assignAll(result.data!);

        // Lấy thông tin tồn phép từ record đầu tiên (hoặc tính tổng)
        // Thông thường API trả về 1 record với thông tin tổng hợp
        final firstVacation = result.data!.first;
        if (firstVacation.phepTon != null) {
          phepTon.value = firstVacation.phepTon!;
        }
        if (firstVacation.overtimeTon != null) {
          overtimeTon.value = firstVacation.overtimeTon!;
        }
      } else {
        // Reset values nếu không có data
        phepTon.value = 0.0;
        overtimeTon.value = 0.0;
        vacationList.clear();
      }
    } catch (e) {
      phepTon.value = 0.0;
      overtimeTon.value = 0.0;
      vacationList.clear();
    }
  }

  /// Load PersonalVacation data (thông tin phép chi tiết) và cache HR_No
  Future<void> loadPersonalVacation() async {
    if (getPersonalVacationUsecase == null) {
      return;
    }

    // Đảm bảo userProfile đã có và có hrId
    final profile = userProfile.value;
    if (profile == null) {
      return;
    }

    // Nếu HR_ID = 0 hoặc null, dùng giá trị mặc định 1752
    final hrId = profile.hrId > 0 ? profile.hrId : 1752;

    try {
      final result = await getPersonalVacationUsecase!.call(hrId: hrId);

      if (result.isSuccess && result.data != null) {
        // Cache PersonalVacation
        personalVacation.value = result.data;
      } else {
        personalVacation.value = null;
      }
    } catch (e) {
      personalVacation.value = null;
    }
  }
}
