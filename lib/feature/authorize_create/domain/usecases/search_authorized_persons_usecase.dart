import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize_create/domain/repositories/authorize_create_repository.dart';

class SearchAuthorizedPersonsUsecase {
  final AuthorizeCreateRepository repository;

  SearchAuthorizedPersonsUsecase({required this.repository});

  Future<ApiResult<List<Map<String, dynamic>>>> call(
    String token,
    String query,
  ) async {
    return await repository.searchAuthorizedPersons(token, query);
  }
}

