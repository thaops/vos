import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/feature/profile/data/models/user_profile_dto.dart';

abstract class ProfileLocalDataSource {
  Future<void> saveUserProfile(UserProfileDto dto);
  Future<UserProfileDto?> getUserProfile();
  Future<void> saveViagsStatus(bool linked, String email);
  Future<Map<String, dynamic>> getViagsStatus();
  Future<void> saveEmployeeStatus(bool isEmployee);
  Future<bool> getEmployeeStatus();
  Future<void> saveViagsCredentials(String name, String password);
  Future<Map<String, String?>> getViagsCredentials();
  Future<void> unlinkViagsAccount();
  Future<void> clearAll();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final GetStorage _storage = GetStorage();

  @override
  Future<void> saveUserProfile(UserProfileDto dto) async {
    try {
      await _storage.write('user_profile_data', dto.toJson());
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfileDto?> getUserProfile() async {
    try {
      final userData = _storage.read('user_profile_data');
      if (userData != null) {
        return UserProfileDto.fromJson(
            Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<void> saveViagsStatus(bool linked, String email) async {
    try {
      await _storage.write('viags_linked', linked);
      await _storage.write('viags_email', email);
    } catch (e) {
      print('Error saving VIAGS status: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getViagsStatus() async {
    try {
      return {
        'isLinked': _storage.read<bool>('viags_linked') ?? false,
        'email': _storage.read<String>('viags_email') ?? '',
      };
    } catch (e) {
      print('Error getting VIAGS status: $e');
      return {'isLinked': false, 'email': ''};
    }
  }

  @override
  Future<void> saveEmployeeStatus(bool isEmployee) async {
    try {
      await _storage.write('is_employee', isEmployee);
    } catch (e) {
      print('Error saving employee status: $e');
      rethrow;
    }
  }

  @override
  Future<bool> getEmployeeStatus() async {
    try {
      return _storage.read<bool>('is_employee') ?? false;
    } catch (e) {
      print('Error getting employee status: $e');
      return false;
    }
  }

  @override
  Future<void> saveViagsCredentials(String name, String password) async {
    try {
      await _storage.write('saved_viags_name', name);
      await _storage.write('saved_viags_password', password);
    } catch (e) {
      print('Error saving VIAGS credentials: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String?>> getViagsCredentials() async {
    try {
      return {
        'name': _storage.read<String>('saved_viags_name'),
        'password': _storage.read<String>('saved_viags_password'),
      };
    } catch (e) {
      print('Error getting VIAGS credentials: $e');
      return {'name': null, 'password': null};
    }
  }

  @override
  Future<void> unlinkViagsAccount() async {
    try {
      // Giữ lại name và password trước khi xóa
      final savedName = _storage.read<String>('saved_viags_name');
      final savedPassword = _storage.read<String>('saved_viags_password');
      
      // Xóa profile VACS
      await _storage.remove('user_profile_data');
      
      // Xóa trạng thái liên kết
      await _storage.remove('viags_linked');
      await _storage.remove('viags_email');
      
      // Xóa employee status
      await _storage.remove('is_employee');
      
      // Khôi phục name và password (nếu có)
      if (savedName != null && savedName.isNotEmpty) {
        await _storage.write('saved_viags_name', savedName);
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        await _storage.write('saved_viags_password', savedPassword);
      }
    } catch (e) {
      print('Error unlinking VIAGS account: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      // Giữ lại name và password trước khi clear
      final savedName = _storage.read<String>('saved_viags_name');
      final savedPassword = _storage.read<String>('saved_viags_password');
      
      // Clear tất cả
      await _storage.erase();
      
      // Khôi phục name và password
      if (savedName != null && savedName.isNotEmpty) {
        await _storage.write('saved_viags_name', savedName);
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        await _storage.write('saved_viags_password', savedPassword);
      }
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }
}

