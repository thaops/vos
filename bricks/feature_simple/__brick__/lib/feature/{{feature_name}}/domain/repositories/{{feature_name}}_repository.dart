import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/{{feature_name}}/domain/models/{{model_name}}.dart';

abstract class {{feature_name.pascalCase()}}Repository {
  Future<ApiResult<List<{{model_name.pascalCase()}}>>> get{{model_name.pascalCase()}}List();
}

