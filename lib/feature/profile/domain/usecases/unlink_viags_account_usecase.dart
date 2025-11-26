import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';

class UnlinkViagsAccountUsecase {
  final ProfileRepository repository;

  UnlinkViagsAccountUsecase(this.repository);

  Future<ApiResult<void>> call() async {
    return await repository.unlinkViagsAccount();
  }
}

