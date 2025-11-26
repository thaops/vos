import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserProfile>> getUserProfile();
  Future<ApiResult<UserProfile>> linkViagsAccount(String name, String password);
  Future<ApiResult<void>> unlinkViagsAccount();
  Future<ApiResult<void>> logout();
  Future<Map<String, dynamic>> getViagsStatus();
  Future<bool> getEmployeeStatus();
}

