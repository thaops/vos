import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize_create/domain/repositories/authorize_create_repository.dart';

class CreateAuthorizeUsecase {
  final AuthorizeCreateRepository repository;

  CreateAuthorizeUsecase({required this.repository});

  Future<ApiResult<String>> call(
    String token,
    Map<String, dynamic> payload,
  ) async {
    return await repository.createAuthorize(token, payload);
  }
}

