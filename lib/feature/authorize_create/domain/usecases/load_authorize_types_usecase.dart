import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize_create/domain/repositories/authorize_create_repository.dart';

class LoadAuthorizeTypesUsecase {
  final AuthorizeCreateRepository repository;

  LoadAuthorizeTypesUsecase({required this.repository});

  Future<ApiResult<List<Map<String, String>>>> call(String token) async {
    return await repository.loadAuthorizeTypes(token);
  }
}

