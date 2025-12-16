import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';

abstract class AuthorizeRepository {
  Future<ApiResult<List<Authorize>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year);

  Future<ApiResult<void>> cancelAuthorize({
    required String token,
    required int authorizeId,
    required String fromDate,
    required String lsAuthorize,
  });

  Future<ApiResult<List<Map<String, String>>>> getAuthorizeStatuses(
      String token);
}

