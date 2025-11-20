import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/login/domain/repositories/login_repository.dart';

class SignOutUsecase {
  final LoginRepository loginRepository;
  SignOutUsecase({required this.loginRepository});
  Future<ApiResult<void>> call() async {
    return await loginRepository.signOut();
  }
}
