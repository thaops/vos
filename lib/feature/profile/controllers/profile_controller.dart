import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/feature/profile/models/user_profile_model.dart';

class ProfileController extends GetxController {
  final GetStorage _storage = GetStorage();

  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final Rx<GoogleUserDto?> googleUser = Rx<GoogleUserDto?>(null);
  final RxBool isLoading = false.obs;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  final RxBool isViagsLinked = false.obs;
  final RxString viagsEmail = ''.obs;

  final RxBool isEmployee = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _loadGoogleUser();
    _loadViagsStatus();
    _loadEmployeeStatus();
  }

  void _loadViagsStatus() {
    isViagsLinked.value = _storage.read<bool>('viags_linked') ?? false;
    viagsEmail.value = _storage.read<String>('viags_email') ?? '';
  }

  void _loadEmployeeStatus() {
    isEmployee.value = _storage.read<bool>('is_employee') ?? false;
  }

  void reloadEmployeeStatus() {
    _loadEmployeeStatus();
  }

  void reloadViagsStatus() {
    _loadViagsStatus();
  }

  void _loadGoogleUser() {
    try {
      final box = Hive.box('google_user_box');
      final userData = box.get('current_user');
      if (userData != null) {
        googleUser.value = GoogleUserDto.fromJson(
          Map<String, dynamic>.from(userData),
        );
      } else {
        googleUser.value = null;
      }
    } catch (e) {
      googleUser.value = null;
    }
  }

  void refreshGoogleUser() {
    _loadGoogleUser();
  }

  void _loadUserProfile() {
    try {
      final userData = _storage.read('user_profile_data');
      if (userData != null) {
        userProfile.value = UserProfileModel.fromJson(userData);
      } else {
        final hasIndividualKeys =
            _storage.read('user_id') != null ||
            _storage.read('user_code') != null;
        if (hasIndividualKeys) {
          _loadFromIndividualKeys();
        } else {
          userProfile.value = null;
        }
      }
    } catch (e) {
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
      // Ignore
    }
  }

  void saveUserProfile(Map<String, dynamic> data) {
    try {
      _storage.write('user_profile_data', data);
      userProfile.value = UserProfileModel.fromJson(data);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> logout() async {
    try {
      _isLoggingOut = true;

      await FirebaseAuth.instance.signOut();

      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.disconnect();

      final box = Hive.box('google_user_box');
      await box.delete('current_user');

      await _storage.erase();
    } catch (e) {
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
        await _storage.erase();
      } catch (_) {
        // Ignore
      }
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isLoggingOut = false;
      });
    }
  }

  Future<bool> linkViagsAccount(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      _storage.write('viags_linked', true);
      _storage.write('viags_email', email);

      isViagsLinked.value = true;
      viagsEmail.value = email;

      if (googleUser.value != null) {
        try {
          final box = Hive.box('google_user_box');
          final googleUserData = googleUser.value!.toJson();
          googleUserData['email'] = email;
          await box.put('current_user', googleUserData);
          googleUser.value = GoogleUserDto.fromJson(googleUserData);
          googleUser.refresh();
        } catch (e) {
          // Ignore
        }
      }

      if (userProfile.value != null) {
        final currentData = userProfile.value!.toJson();
        currentData['Email'] = email;
        saveUserProfile(currentData);
        userProfile.value = UserProfileModel.fromJson(currentData);
        userProfile.refresh();
      } else {
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

      _storage.write('is_employee', true);
      isEmployee.value = true;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> unlinkViagsAccount(BuildContext context) async {
    try {
      _storage.remove('viags_linked');
      _storage.remove('viags_email');
      _storage.write('is_employee', false);

      isViagsLinked.value = false;
      viagsEmail.value = '';
      isEmployee.value = false;

      reloadViagsStatus();
      reloadEmployeeStatus();
    } catch (e) {
      // Ignore
    }
  }

  String get displayName => userProfile.value?.userName ?? 'Người dùng';
  String get userCode => userProfile.value?.userCode ?? '';
  String get companyName => userProfile.value?.companyNameVN ?? '';
  String get email {
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
