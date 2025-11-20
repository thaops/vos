import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/news_detail/data/models/news_detail_dto.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

abstract class NewsDetailRemoteDataSource {
  Future<ApiResult<List<NewsDetail>>> getNews();

  Future<ApiResult<NewsDetail>> getArticleDetail(String id);

  Future<ApiResult<List<NewsDetail>>> searchNews(String query);

  Future<ApiResult<void>> createArticle(NewsDetailDto item);

  Future<ApiResult<bool>> updateArticle(NewsDetailDto item);

  Future<ApiResult<bool>> deleteArticle(String id);
}

class NewsDetailRemoteDataSourceImpl implements NewsDetailRemoteDataSource {
  final DioApi dioApi;

  String get _baseUrl => Config.baseUrl;
  String get _newsDetailUrl => '$_baseUrl/newss/getnewsbyid';

  NewsDetailRemoteDataSourceImpl({required this.dioApi});

  @override
  Future<ApiResult<List<NewsDetail>>> getNews() async {
    try {
      // getNews không được sử dụng trong flow hiện tại
      return ApiResult.success([]);
    } catch (e) {
      return ApiResult.error('getNews failed: $e');
    }
  }

  @override
  Future<ApiResult<NewsDetail>> getArticleDetail(String id) async {
    try {
      final response = await dioApi.post(
        _newsDetailUrl,
        data: {'Id': int.tryParse(id) ?? id},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        // Kiểm tra StatusCode từ API
        final statusCode = responseData['StatusCode'] as int?;
        if (statusCode != 200) {
          final message = responseData['Message'] as String? ?? 'Unknown error';
          return ApiResult.error(message);
        }

        final data = responseData['Data'] as Map<String, dynamic>?;
        if (data != null) {
          try {
            final dto = NewsDetailDto.fromJson(data);
            return ApiResult.success(dto.toDomain());
          } catch (e) {
            return ApiResult.error('Parse error: $e');
          }
        }
        return ApiResult.error('No data found');
      }
      return ApiResult.error('Invalid response status: ${response.statusCode}');
    } catch (e) {
      return ApiResult.error('getArticleDetail failed: $e');
    }
  }

  @override
  Future<ApiResult<List<NewsDetail>>> searchNews(String query) async {
    try {
      // searchNews không được sử dụng trong flow hiện tại
      return ApiResult.success([]);
    } catch (e) {
      return ApiResult.error('searchNews failed: $e');
    }
  }

  @override
  Future<ApiResult<void>> createArticle(NewsDetailDto item) async {
    try {
      final response = await dioApi.post(_newsDetailUrl, data: item.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(null);
      }
      return ApiResult.error(
        'Create failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.error('createArticle failed: $e');
    }
  }

  @override
  Future<ApiResult<bool>> updateArticle(NewsDetailDto item) async {
    try {
      final response = await dioApi.put(
        '$_newsDetailUrl/${item.id}',
        data: item.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResult.success(true);
      }
      return ApiResult.error(
        'Update failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.error('updateArticle failed: $e');
    }
  }

  @override
  Future<ApiResult<bool>> deleteArticle(String id) async {
    try {
      final response = await dioApi.delete('$_newsDetailUrl/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResult.success(true);
      }
      return ApiResult.error(
        'Delete failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.error('deleteArticle failed: $e');
    }
  }
}
