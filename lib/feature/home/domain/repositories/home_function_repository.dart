import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/home/domain/models/home_function.dart';

abstract class HomeFunctionRepository {
  Future<ApiResult<List<HomeFunctionSession>>> getHomeFunctions(
      String token, String lsStatus);
}

