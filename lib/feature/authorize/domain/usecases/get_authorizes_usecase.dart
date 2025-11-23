import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';
import 'package:vos_flutter/feature/authorize/domain/repositories/authorize_repository.dart';

class GetAuthorizesUsecase {
  final AuthorizeRepository repository;

  GetAuthorizesUsecase({required this.repository});

  Future<ApiResult<List<Authorize>>> call(
      String token, int authorizeId, int hrId, int year) {
    return repository.getAuthorizes(token, authorizeId, hrId, year);
  }
}

