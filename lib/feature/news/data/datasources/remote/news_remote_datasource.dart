import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/news/data/models/news_dto.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';
import 'package:vos_flutter/core/network/api_endpoints.dart';

abstract class NewsRemoteDataSource {
  Future<ApiResult<List<News>>> getNews({int page = 1, int limit = 10});

  Future<ApiResult<News>> getArticleDetail(String id);

  Future<ApiResult<List<News>>> searchNews(
    String query, {
    int page = 1,
    int limit = 10,
  });

  Future<ApiResult<void>> createArticle(NewsDto item);

  Future<ApiResult<bool>> updateArticle(NewsDto item);

  Future<ApiResult<bool>> deleteArticle(String id);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final DioApi dioApi;

  // News API luôn dùng URL của NPP
  String get _baseUrl => Config.baseUrlNpp;
  String get _newsListUrl => '$_baseUrl${ApiEndpoints.newsList}';

  NewsRemoteDataSourceImpl({required this.dioApi});

  @override
  Future<ApiResult<List<News>>> getNews({int page = 1, int limit = 10}) async {
    try {
      final response = await dioApi.post(_newsListUrl, data: {'Keyword': ''});

      return _parseApiResponse(response);
    } catch (e) {
      return ApiResult.error('getNews failed: $e');
    }
  }

  @override
  Future<ApiResult<News>> getArticleDetail(String id) async {
    try {
      final result = await getNews(limit: 100);
      if (result.isSuccess && result.data != null) {
        final article = result.data!.firstWhere(
          (item) => item.id == id,
          orElse: () => throw Exception('Article not found'),
        );
        return ApiResult.success(article);
      }
      return ApiResult.error('getArticleDetail failed: Article not found');
    } catch (e) {
      return ApiResult.error('getArticleDetail failed: $e');
    }
  }

  @override
  Future<ApiResult<List<News>>> searchNews(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dioApi.post(
        _newsListUrl,
        data: {'Keyword': query},
      );

      return _parseApiResponse(response);
    } catch (e) {
      return ApiResult.error('searchNews failed: $e');
    }
  }

  // Helper method để parse response từ API
  ApiResult<List<News>> _parseApiResponse(dynamic response) {
    try {
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        // Kiểm tra StatusCode từ API
        final statusCode = responseData['StatusCode'] as int?;
        if (statusCode != 200) {
          final message = responseData['Message'] as String? ?? 'Unknown error';
          return ApiResult.error(message);
        }

        final dataList = responseData['Data'] as List?;

        if (dataList != null && dataList.isNotEmpty) {
          final parsedList = dataList
              .map((item) {
                try {
                  return NewsDto.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing article: $e');
                  return null;
                }
              })
              .whereType<NewsDto>()
              .toList();

          if (parsedList.isNotEmpty) {
            final domainList = parsedList.map((dto) => dto.toDomain()).toList();
            return ApiResult.success(domainList);
          }
        }
        return ApiResult.success([]);
      }
      return ApiResult.error('Invalid response status: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('❌ Parse error: $e');
      print('Stack trace: $stackTrace');
      return ApiResult.error('Parse error: $e');
    }
  }

  @override
  Future<ApiResult<void>> createArticle(NewsDto item) async {
    try {
      final response = await dioApi.post(_newsListUrl, data: item.toJson());
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
  Future<ApiResult<bool>> updateArticle(NewsDto item) async {
    try {
      final response = await dioApi.put(
        '$_newsListUrl/${item.id}',
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
      final response = await dioApi.delete('$_newsListUrl/$id');
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
