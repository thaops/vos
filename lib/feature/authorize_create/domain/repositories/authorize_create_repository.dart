import 'package:vos_flutter/common/utils/api_response_handler.dart';

abstract class AuthorizeCreateRepository {
  Future<ApiResult<List<Map<String, dynamic>>>> searchAuthorizedPersons(
    String token,
    String query,
  );

  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeTypes(String token);

  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeStatuses(
    String token,
  );

  Future<ApiResult<String>> createAuthorize(
    String token,
    Map<String, dynamic> payload,
  );
}
