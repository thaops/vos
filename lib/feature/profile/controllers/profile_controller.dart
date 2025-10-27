import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/feature/profile/models/user_profile_model.dart';

class ProfileController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    try {
      final userData = _storage.read('user_profile_data');
      if (userData != null) {
        userProfile.value = UserProfileModel.fromJson(userData);
      } else {
        // Fallback: load from individual storage keys
        _loadFromIndividualKeys();
      }
    } catch (e) {
      print('Error loading user profile: $e');
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

  void logout() {
    _storage.remove('user_profile_data');
    _storage.remove('is_logged_in');
    _storage.remove('user_id');
    _storage.remove('user_code');
    _storage.remove('user_name');
    _storage.remove('user_token');
    _storage.remove('company_id');
    _storage.remove('company_name');
    _storage.remove('token_expired');
    userProfile.value = null;
  }

  String get displayName => userProfile.value?.userName ?? 'Người dùng';
  String get userCode => userProfile.value?.userCode ?? '';
  String get companyName => userProfile.value?.companyNameVN ?? '';
  String get email => userProfile.value?.email ?? '';
  String get phone => userProfile.value?.phone ?? '';
  String get status => userProfile.value?.status ?? '';
  String get userType => userProfile.value?.userType ?? '';
  String get description => userProfile.value?.description ?? '';
}
