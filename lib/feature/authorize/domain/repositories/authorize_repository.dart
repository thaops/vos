import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';

abstract class AuthorizeRepository {
  Future<ApiResult<List<Authorize>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year);
}

