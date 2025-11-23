import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';

class LinkViagsAccountUsecase {
  final ProfileRepository repository;

  LinkViagsAccountUsecase(this.repository);

  Future<ApiResult<UserProfile>> call(String name, String password) async {
    return await repository.linkViagsAccount(name, password);
  }
}

