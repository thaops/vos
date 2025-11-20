{{#has_remote_api}}
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/{{feature_name}}/data/models/{{model_name}}_dto.dart';
import 'package:vos_flutter/feature/{{feature_name}}/domain/models/{{model_name}}.dart';

abstract class {{feature_name.pascalCase()}}RemoteDataSource {
{{#parsed_usecases}}
  Future<ApiResult<{{#isVoidReturn}}void{{/isVoidReturn}}{{^isVoidReturn}}{{returnType}}{{/isVoidReturn}}>> {{camelName}}({{#hasParams}}{{remoteMethodParams}}{{/hasParams}});
{{/parsed_usecases}}
}

class {{feature_name.pascalCase()}}RemoteDataSourceImpl
    implements {{feature_name.pascalCase()}}RemoteDataSource {
  final DioApi dioApi;
  final String basePath = '{{api_base_path}}';

  {{feature_name.pascalCase()}}RemoteDataSourceImpl({required this.dioApi});

{{#parsed_usecases}}
  @override
  Future<ApiResult<{{#isVoidReturn}}void{{/isVoidReturn}}{{^isVoidReturn}}{{returnType}}{{/isVoidReturn}}>> {{camelName}}({{#hasParams}}{{remoteMethodParams}}{{/hasParams}}) async {
    try {
{{#isList}}
      final response = await dioApi.get(
        basePath,
        params: {
{{#supportsPagination}}
          'page': page,
          'limit': limit,
{{/supportsPagination}}
{{#requiresQueryParam}}
          'search': query,
{{/requiresQueryParam}}
        },
      );
      final parsed = ApiResponseHandler.handleListResponse<{{model_name.pascalCase()}}Dto>(
        response,
        (json) => {{model_name.pascalCase()}}Dto.fromJson(json),
      );
      if (parsed.isSuccess && parsed.data != null) {
        final data =
            parsed.data!.map((dto) => dto.toDomain()).toList();
        return ApiResult.success(data);
      }
      return ApiResult.error(parsed.error ?? '{{camelName}} failed');
{{/isList}}
{{#isDetail}}
      final response = await dioApi.get('$basePath/$id');
      final parsed = ApiResponseHandler.handleResponse<{{model_name.pascalCase()}}Dto>(
        response,
        (json) => {{model_name.pascalCase()}}Dto.fromJson(json),
      );
      if (parsed.isSuccess && parsed.data != null) {
        return ApiResult.success(parsed.data!.toDomain());
      }
      return ApiResult.error(parsed.error ?? '{{camelName}} failed');
{{/isDetail}}
{{#isCreate}}
      final dto = {{model_name.pascalCase()}}Dto.fromDomain(item);
      final response = await dioApi.post(basePath, data: dto.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(null);
      }
      return ApiResult.error('Create failed with status ${response.statusCode}');
{{/isCreate}}
{{#isUpdate}}
      final dto = {{model_name.pascalCase()}}Dto.fromDomain(item);
      final response = await dioApi.put('$basePath/${dto.id}', data: dto.toJson());
      if (response.statusCode == 200 || response.statusCode == 204) {
{{#isBoolReturn}}
        return ApiResult.success(true);
{{/isBoolReturn}}
{{^isBoolReturn}}
        final parsed = ApiResponseHandler.handleResponse<{{model_name.pascalCase()}}Dto>(
          response,
          (json) => {{model_name.pascalCase()}}Dto.fromJson(json),
        );
        if (parsed.isSuccess && parsed.data != null) {
          return ApiResult.success(parsed.data!.toDomain() as {{returnType}});
        }
{{/isBoolReturn}}
      }
      return ApiResult.error('Update failed with status ${response.statusCode}');
{{/isUpdate}}
{{#isDelete}}
      final response = await dioApi.delete('$basePath/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
{{#isBoolReturn}}
        return ApiResult.success(true);
{{/isBoolReturn}}
{{^isBoolReturn}}
        return ApiResult.success(null);
{{/isBoolReturn}}
      }
      return ApiResult.error('Delete failed with status ${response.statusCode}');
{{/isDelete}}
{{^isList}}
{{^isDetail}}
{{^isCreate}}
{{^isUpdate}}
{{^isDelete}}
      // Default GET handler
      final response = await dioApi.get(basePath);
      final parsed = ApiResponseHandler.handleResponse<{{model_name.pascalCase()}}Dto>(
        response,
        (json) => {{model_name.pascalCase()}}Dto.fromJson(json),
      );
      if (parsed.isSuccess && parsed.data != null) {
        return ApiResult.success(parsed.data!.toDomain());
      }
      return ApiResult.error(parsed.error ?? '{{camelName}} failed');
{{/isDelete}}
{{/isUpdate}}
{{/isCreate}}
{{/isDetail}}
{{/isList}}
    } catch (e) {
      return ApiResult.error('{{camelName}} failed: $e');
    }
  }

{{/parsed_usecases}}
}
{{/has_remote_api}}

