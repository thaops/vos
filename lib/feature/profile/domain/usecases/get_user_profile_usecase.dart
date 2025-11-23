import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUsecase {
  final ProfileRepository repository;

  GetUserProfileUsecase(this.repository);

  Future<ApiResult<UserProfile>> call() async {
    return await repository.getUserProfile();
  }
}

