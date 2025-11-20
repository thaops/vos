import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/{{feature_name}}/domain/models/{{model_name}}.dart';

abstract class {{feature_name.pascalCase()}}Repository {
{{#parsed_usecases}}
  Future<ApiResult<{{#isVoidReturn}}void{{/isVoidReturn}}{{^isVoidReturn}}{{returnType}}{{/isVoidReturn}}>> {{camelName}}({{#hasParams}}{{domainMethodParams}}{{/hasParams}});
{{/parsed_usecases}}
}

