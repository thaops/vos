import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/domain/repositories/authorize_repository.dart';

class GetAuthorizeStatusesUsecase {
  final AuthorizeRepository repository;

  GetAuthorizeStatusesUsecase({required this.repository});

  Future<ApiResult<List<Map<String, String>>>> call(String token) {
    return repository.getAuthorizeStatuses(token);
  }
}

