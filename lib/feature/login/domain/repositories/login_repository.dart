import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';

abstract class LoginRepository {
  Future<ApiResult<User>> signInWithGoogle();
  Future<ApiResult<User>> checkAuthState();
  Future<ApiResult<void>> signOut();
}
