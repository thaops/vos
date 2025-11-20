import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';
import 'package:vos_flutter/feature/login/domain/repositories/login_repository.dart';

class  CheckAuthStateUsecase {
  final LoginRepository loginRepository;
  CheckAuthStateUsecase({required this.loginRepository});
  Future<ApiResult<User>> call() async {
    return await loginRepository.checkAuthState();
  }
}