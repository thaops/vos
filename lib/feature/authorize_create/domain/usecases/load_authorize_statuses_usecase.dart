import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize_create/domain/repositories/authorize_create_repository.dart';

class LoadAuthorizeStatusesUsecase {
  final AuthorizeCreateRepository repository;

  LoadAuthorizeStatusesUsecase({required this.repository});

  Future<ApiResult<List<Map<String, String>>>> call(String token) async {
    return await repository.loadAuthorizeStatuses(token);
  }
}

