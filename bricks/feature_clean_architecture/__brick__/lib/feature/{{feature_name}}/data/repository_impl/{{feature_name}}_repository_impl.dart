import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/{{feature_name}}/data/models/{{model_name}}_dto.dart';
{{#has_remote_api}}
import 'package:vos_flutter/feature/{{feature_name}}/data/datasources/remote/{{feature_name}}_remote_datasource.dart';
{{/has_remote_api}}
{{#has_local_storage_enabled}}
import 'package:vos_flutter/feature/{{feature_name}}/data/datasources/local/{{feature_name}}_local_datasource.dart';
{{/has_local_storage_enabled}}
import 'package:vos_flutter/feature/{{feature_name}}/domain/models/{{model_name}}.dart';
import 'package:vos_flutter/feature/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';

class {{feature_name.pascalCase()}}RepositoryImpl implements {{feature_name.pascalCase()}}Repository {
  {{#has_remote_api}}
  final {{feature_name.pascalCase()}}RemoteDataSource remoteDataSource;
  {{/has_remote_api}}
  {{#has_local_storage_enabled}}
  final {{feature_name.pascalCase()}}LocalDataSource localDataSource;
  {{/has_local_storage_enabled}}

  {{feature_name.pascalCase()}}RepositoryImpl({
    {{#has_remote_api}}
    required this.remoteDataSource,
    {{/has_remote_api}}
    {{#has_local_storage_enabled}}
    required this.localDataSource,
    {{/has_local_storage_enabled}}
  });

{{#parsed_usecases}}
  @override
  Future<ApiResult<{{#isVoidReturn}}void{{/isVoidReturn}}{{^isVoidReturn}}{{returnType}}{{/isVoidReturn}}>> {{camelName}}({{#hasParams}}{{domainMethodParams}}{{/hasParams}}) async {
{{#isList}}
    {{#has_local_storage_enabled}}
    {{#listOfDomainModel}}
    {{^requiresQueryParam}}
    {{#supportsPagination}}
    {{#has_full_cache_enabled}}
    final cachedPage = await localDataSource.get{{model_name_pascal}}Page(page);
    if (cachedPage != null && cachedPage.isNotEmpty) {
      return ApiResult.success(
        cachedPage.map((dto) => dto.toDomain()).toList(),
      );
    }
    {{/has_full_cache_enabled}}
    {{^has_full_cache_enabled}}
    if (page == 1) {
      final cachedList = await localDataSource.get{{model_name_pascal}}List();
      if (cachedList.isNotEmpty) {
        return ApiResult.success(
          cachedList.map((dto) => dto.toDomain()).toList(),
        );
      }
    }
    {{/has_full_cache_enabled}}
    {{/supportsPagination}}
    {{^supportsPagination}}
    final cachedList = await localDataSource.get{{model_name_pascal}}List();
    if (cachedList.isNotEmpty) {
      return ApiResult.success(
        cachedList.map((dto) => dto.toDomain()).toList(),
      );
    }
    {{/supportsPagination}}
    {{/requiresQueryParam}}
    {{/listOfDomainModel}}
    {{/has_local_storage_enabled}}

    {{#has_remote_api}}
    final result = await remoteDataSource.{{camelName}}({{#hasParams}}{{methodCallArgs}}{{/hasParams}});

    {{#has_local_storage_enabled}}
    {{#listOfDomainModel}}
    {{^requiresQueryParam}}
    if (result.isSuccess && result.data != null) {
      final dtoList = result.data!
          .map((item) => {{model_name_pascal}}Dto.fromDomain(item))
          .toList();
      {{#supportsPagination}}
      {{#has_full_cache_enabled}}
      await localDataSource.save{{model_name_pascal}}Page(page, dtoList);
      {{/has_full_cache_enabled}}
      {{^has_full_cache_enabled}}
      if (page == 1) {
        await localDataSource.save{{model_name_pascal}}List(dtoList);
      }
      {{/has_full_cache_enabled}}
      {{/supportsPagination}}
      {{^supportsPagination}}
      await localDataSource.save{{model_name_pascal}}List(dtoList);
      {{/supportsPagination}}
    }
    {{/requiresQueryParam}}
    {{/listOfDomainModel}}
    {{/has_local_storage_enabled}}
    return result;
    {{/has_remote_api}}
    {{^has_remote_api}}
    throw UnimplementedError('{{camelName}} is not available without remote API');
    {{/has_remote_api}}
{{/isList}}
{{^isList}}
{{#isCreate}}
    {{#has_remote_api}}
    final result = await remoteDataSource.{{camelName}}({{#hasParams}}{{methodCallArgs}}{{/hasParams}});
    {{#has_local_storage_enabled}}
    if (result.isSuccess) {
      await localDataSource.save{{model_name_pascal}}({{model_name_pascal}}Dto.fromDomain(item));
    }
    {{/has_local_storage_enabled}}
    return result;
    {{/has_remote_api}}
    {{^has_remote_api}}
    throw UnimplementedError('Create flow requires remote API');
    {{/has_remote_api}}
{{/isCreate}}
{{#isUpdate}}
    {{#has_remote_api}}
    final result = await remoteDataSource.{{camelName}}({{#hasParams}}{{methodCallArgs}}{{/hasParams}});
    {{#has_local_storage_enabled}}
    if (result.isSuccess) {
      await localDataSource.save{{model_name_pascal}}({{model_name_pascal}}Dto.fromDomain(item));
    }
    {{/has_local_storage_enabled}}
    return result;
    {{/has_remote_api}}
    {{^has_remote_api}}
    throw UnimplementedError('Update flow requires remote API');
    {{/has_remote_api}}
{{/isUpdate}}
{{#isDelete}}
    {{#has_remote_api}}
    final result = await remoteDataSource.{{camelName}}({{#hasParams}}{{methodCallArgs}}{{/hasParams}});
    {{#has_local_storage_enabled}}
    if (result.isSuccess) {
      await localDataSource.clear{{model_name_pascal}}(id);
    }
    {{/has_local_storage_enabled}}
    return result;
    {{/has_remote_api}}
    {{^has_remote_api}}
    throw UnimplementedError('Delete flow requires remote API');
    {{/has_remote_api}}
{{/isDelete}}
{{#isDetail}}
    {{#has_remote_api}}
    final result = await remoteDataSource.{{camelName}}({{#hasParams}}{{methodCallArgs}}{{/hasParams}});
    {{#has_local_storage_enabled}}
    if (result.isSuccess && result.data != null && {{#requiresIdParam}}id.isNotEmpty{{/requiresIdParam}}{{^requiresIdParam}}true{{/requiresIdParam}}) {
      await localDataSource.save{{model_name_pascal}}(
        {{model_name_pascal}}Dto.fromDomain(result.data!),
      );
    }
    {{/has_local_storage_enabled}}
    return result;
    {{/has_remote_api}}
    {{^has_remote_api}}
    {{#has_local_storage_enabled}}
    {{#requiresIdParam}}
    final cachedItem = await localDataSource.get{{model_name_pascal}}(id);
    if (cachedItem != null) {
      return ApiResult.success(cachedItem.toDomain());
    }
    {{/requiresIdParam}}
    {{/has_local_storage_enabled}}
    throw UnimplementedError('Remote API disabled for {{camelName}}');
    {{/has_remote_api}}
{{/isDetail}}
{{^isCreate}}
{{^isUpdate}}
{{^isDelete}}
{{^isDetail}}
    {{#has_remote_api}}
    return await remoteDataSource.{{camelName}}({{#hasParams}}{{methodCallArgs}}{{/hasParams}});
    {{/has_remote_api}}
    {{^has_remote_api}}
    throw UnimplementedError('{{camelName}} not implemented');
    {{/has_remote_api}}
{{/isDetail}}
{{/isDelete}}
{{/isUpdate}}
{{/isCreate}}
{{/isList}}
  }

{{/parsed_usecases}}
}


