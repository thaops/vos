import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vos_flutter/feature/profile/models/user_profile_model.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/models/google_user_model.dart';

class ProfileController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final Rx<GoogleUserModel?> googleUser = Rx<GoogleUserModel?>(null);
  final RxBool isLoading = false.obs;

  // Flag để track logout state - ngăn Obx() rebuild khi đang logout
  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  // Flag để track trạng thái liên kết VIAGS (reactive)
  final RxBool isViagsLinked = false.obs;
  final RxString viagsEmail = ''.obs;

  // Flag để track trạng thái nhân viên (reactive)
  final RxBool isEmployee = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _loadGoogleUser();
    _loadViagsStatus();
    _loadEmployeeStatus();
  }

  /// Load trạng thái liên kết VIAGS
  void _loadViagsStatus() {
    isViagsLinked.value = _storage.read<bool>('viags_linked') ?? false;
    viagsEmail.value = _storage.read<String>('viags_email') ?? '';
  }

  /// Load trạng thái nhân viên
  void _loadEmployeeStatus() {
    isEmployee.value = _storage.read<bool>('is_employee') ?? false;
  }

  /// Reload trạng thái nhân viên từ storage (public method để gọi từ bên ngoài)
  void reloadEmployeeStatus() {
    _loadEmployeeStatus();
  }

  /// Reload trạng thái liên kết VIAGS từ storage (public method để gọi từ bên ngoài)
  void reloadViagsStatus() {
    _loadViagsStatus();
  }

  void _loadGoogleUser() {
    try {
      final box = Hive.box('google_user_box');
      final userData = box.get('current_user');
      if (userData != null) {
        googleUser.value = GoogleUserModel.fromJson(
          Map<String, dynamic>.from(userData),
        );
        print('✅ Loaded Google user: ${googleUser.value?.displayName}');
      } else {
        // Storage đã xóa (sau logout) → clear reactive value
        googleUser.value = null;
        print('⚠️ No Google user found in Hive');
      }
    } catch (e) {
      print('❌ Error loading Google user: $e');
      googleUser.value = null;
    }
  }

  /// Refresh Google user from Hive (call after login)
  void refreshGoogleUser() {
    _loadGoogleUser();
  }

  void _loadUserProfile() {
    try {
      final userData = _storage.read('user_profile_data');
      if (userData != null) {
        userProfile.value = UserProfileModel.fromJson(userData);
      } else {
        // Fallback: load from individual storage keys
        final hasIndividualKeys =
            _storage.read('user_id') != null ||
            _storage.read('user_code') != null;
        if (hasIndividualKeys) {
          _loadFromIndividualKeys();
        } else {
          // Storage đã xóa hoàn toàn (sau logout) → clear reactive value
          userProfile.value = null;
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      userProfile.value = null;
    }
  }

  void _loadFromIndividualKeys() {
    try {
      final userData = {
        'UserID': _storage.read('user_id') ?? 0,
        'Company_ID': _storage.read('company_id') ?? 0,
        'UserCode': _storage.read('user_code') ?? '',
        'UserName': _storage.read('user_name') ?? '',
        'UserType': 'U',
        'BrieftName': _storage.read('user_code') ?? '',
        'Token': _storage.read('user_token') ?? '',
        'TokenExpired': _storage.read('token_expired') ?? '',
        'Language': 'VN',
        'Devices': '',
        'Description': 'Dùng để truy xuất API thông tin phép',
        'Attribute': 'O',
        'Email': '',
        'Phone': '',
        'Status': 'OK',
        'Pwd_Level': 'DIFFICULT',
        'RecUserID': 0,
        'NewPassword': '',
        'CompanyCode': 'VIAGS',
        'CompanyName_VN': _storage.read('company_name') ?? '',
        'CompanyName_EN': 'VietNam Internal Airport Ground Services',
        'MasterCompany_ID': _storage.read('company_id') ?? 0,
        'MasterCompanyCode': 'VIAGS',
        'MasterCompanyName_VN': _storage.read('company_name') ?? '',
        'MasterCompanyName_EN': 'VietNam Internal Airport Ground Services',
        'Branch_ID': 0,
        'BranchCode': '',
        'BranchName_VN': '',
        'BranchName_EN': '',
        'HR_ID': 0,
        'HR_No': '',
        'Login_Type': 'EAF',
      };

      userProfile.value = UserProfileModel.fromJson(userData);
    } catch (e) {
      print('Error loading from individual keys: $e');
    }
  }

  void saveUserProfile(Map<String, dynamic> data) {
    try {
      _storage.write('user_profile_data', data);
      userProfile.value = UserProfileModel.fromJson(data);
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  /// Đăng xuất: xóa cache, đăng xuất Google, trở về màn hình login
  /// Lưu ý: KHÔNG thay đổi reactive values để tránh mutate disposed widgets (chart trong home_tab)
  /// Reactive values sẽ tự reset khi vào lại profile screen (storage đã xóa → onInit() không tìm thấy data)
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

      // 4. Clear GetStorage (user profile và tất cả cache, bao gồm viags_linked và is_employee)
      await _storage.erase();

      // KHÔNG thay đổi reactive values (isLoading, userProfile, googleUser) ở đây vì:
      // - home_tab.dart có Obx() listen userProfile/googleUser → trigger rebuild chart đang dispose
      // - isLoading.value = false có thể trigger rebuild → mutate disposed widgets
      // - Khi vào lại profile screen, onInit() sẽ load lại và không tìm thấy data → tự động null
      // - Tránh được lỗi "disposed RenderObject was mutated"
      // Flag _isLoggingOut sẽ được reset khi controller được dispose hoặc recreate
    } catch (e) {
      print('❌ Logout error: $e');

      // Fallback: vẫn clear data ngay cả khi sign out lỗi
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
        await _storage.erase();
        // KHÔNG thay đổi reactive values
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

  /// Liên kết tài khoản VIAGS (giả lập)
  Future<bool> linkViagsAccount(String email, String password) async {
    try {
      // Giả lập API call - trong thực tế sẽ gọi API thật
      await Future.delayed(const Duration(seconds: 1));

      // Lưu trạng thái đã liên kết
      _storage.write('viags_linked', true);
      _storage.write('viags_email', email);

      // Cập nhật reactive values NGAY LẬP TỨC (không delay)
      // Để đảm bảo UI cập nhật trước khi navigate
      isViagsLinked.value = true;
      viagsEmail.value = email;

      // Cập nhật email trong GoogleUserModel nếu có
      if (googleUser.value != null) {
        try {
          final box = Hive.box('google_user_box');
          final googleUserData = googleUser.value!.toJson();
          googleUserData['email'] = email; // Cập nhật email mới
          await box.put('current_user', googleUserData);
          // Cập nhật reactive value
          googleUser.value = GoogleUserModel.fromJson(googleUserData);
          googleUser.refresh();
        } catch (e) {
          print('⚠️ Error updating Google user email: $e');
        }
      }

      // Cập nhật email trong userProfile và lưu vào storage
      if (userProfile.value != null) {
        final currentData = userProfile.value!.toJson();
        currentData['Email'] = email; // Cập nhật email mới
        saveUserProfile(currentData);
        // Trigger update ngay để userProfile.value?.email được cập nhật
        userProfile.value = UserProfileModel.fromJson(currentData);
        // Refresh để trigger Obx() rebuild
        userProfile.refresh();
      } else {
        // Nếu chưa có userProfile, tạo mới với email
        final newData = {
          'UserID': _storage.read('user_id') ?? 0,
          'Company_ID': _storage.read('company_id') ?? 0,
          'UserCode': _storage.read('user_code') ?? '',
          'UserName': _storage.read('user_name') ?? '',
          'UserType': 'U',
          'BrieftName': _storage.read('user_code') ?? '',
          'Token': _storage.read('user_token') ?? '',
          'TokenExpired': _storage.read('token_expired') ?? '',
          'Language': 'VN',
          'Devices': '',
          'Description': 'Dùng để truy xuất API thông tin phép',
          'Attribute': 'O',
          'Email': email,
          'Phone': _storage.read('phone') ?? '',
          'Status': 'OK',
          'Pwd_Level': 'DIFFICULT',
          'RecUserID': 0,
          'NewPassword': '',
          'CompanyCode': 'VIAGS',
          'CompanyName_VN': _storage.read('company_name') ?? '',
          'CompanyName_EN': 'VietNam Internal Airport Ground Services',
          'MasterCompany_ID': _storage.read('company_id') ?? 0,
          'MasterCompanyCode': 'VIAGS',
          'MasterCompanyName_VN': _storage.read('company_name') ?? '',
          'MasterCompanyName_EN': 'VietNam Internal Airport Ground Services',
          'Branch_ID': 0,
          'BranchCode': '',
          'BranchName_VN': '',
          'BranchName_EN': '',
          'HR_ID': 0,
          'HR_No': '',
          'Login_Type': 'EAF',
        };
        saveUserProfile(newData);
      }

      // Khi liên kết VIAGS thành công → tự động set is_employee = true để hiển thị tab Home
      _storage.write('is_employee', true);
      isEmployee.value = true;

      return true;
    } catch (e) {
      print('❌ Error linking VIAGS account: $e');
      return false;
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
}
