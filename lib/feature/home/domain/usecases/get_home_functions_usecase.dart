import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/home/domain/models/home_function.dart';
import 'package:vos_flutter/feature/home/domain/repositories/home_function_repository.dart';

class GetHomeFunctionsUsecase {
  final HomeFunctionRepository repository;

  GetHomeFunctionsUsecase(this.repository);

  Future<ApiResult<List<HomeFunctionSession>>> call(
      String token, String lsStatus) async {
    return await repository.getHomeFunctions(token, lsStatus);
  }
}

