import 'package:get/get.dart';
{{#has_remote_api}}
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/{{feature_name}}/data/datasources/remote/{{feature_name}}_remote_datasource.dart';
{{/has_remote_api}}
{{#has_local_storage_enabled}}
import 'package:vos_flutter/feature/{{feature_name}}/data/datasources/local/{{feature_name}}_local_datasource.dart';
{{/has_local_storage_enabled}}
import 'package:vos_flutter/feature/{{feature_name}}/data/repository_impl/{{feature_name}}_repository_impl.dart';
import 'package:vos_flutter/feature/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';
{{#parsed_usecases}}
import 'package:vos_flutter/feature/{{feature_name}}/domain/usecases/{{snakeName}}_usecase.dart';
{{/parsed_usecases}}
import 'package:vos_flutter/feature/{{feature_name}}/presentation/controller/{{feature_name}}_controller.dart';

class {{feature_name.pascalCase()}}Binding extends Bindings {
  @override
  void dependencies() {
    {{#has_remote_api}}
    Get.lazyPut<{{feature_name.pascalCase()}}RemoteDataSource>(
      () => {{feature_name.pascalCase()}}RemoteDataSourceImpl(
        dioApi: Get.find<DioApi>(),
      ),
    );
    {{/has_remote_api}}

    {{#has_local_storage_enabled}}
    Get.lazyPut<{{feature_name.pascalCase()}}LocalDataSource>(
      () => {{feature_name.pascalCase()}}LocalDataSourceImpl(),
    );
    {{/has_local_storage_enabled}}

    Get.lazyPut<{{feature_name.pascalCase()}}Repository>(
      () => {{feature_name.pascalCase()}}RepositoryImpl(
        {{#has_remote_api}}remoteDataSource: Get.find<{{feature_name.pascalCase()}}RemoteDataSource>(),{{/has_remote_api}}
        {{#has_local_storage_enabled}}localDataSource: Get.find<{{feature_name.pascalCase()}}LocalDataSource>(),{{/has_local_storage_enabled}}
      ),
    );

    {{#parsed_usecases}}
    Get.lazyPut<{{className}}>(
      () => {{className}}(repository: Get.find<{{feature_name.pascalCase()}}Repository>()),
    );
    {{/parsed_usecases}}

    Get.lazyPut<{{feature_name.pascalCase()}}Controller>(
      () => {{feature_name.pascalCase()}}Controller(
        {{#parsed_usecases}}
        {{camelName}}Usecase: Get.find<{{className}}>(),
        {{/parsed_usecases}}
      ),
    );
  }
}


