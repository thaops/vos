import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';

abstract class NewsRepository {
  Future<ApiResult<List<News>>> getNews({
    int page = 1,
    int limit = 10,
    String keyword = '',
  });

  Future<ApiResult<News>> getArticleDetail(String id);

  Future<ApiResult<List<News>>> searchNews(
    String query, {
    int page = 1,
    int limit = 10,
  });

  Future<ApiResult<void>> createArticle(News item);

  Future<ApiResult<bool>> updateArticle(News item);

  Future<ApiResult<bool>> deleteArticle(String id);
}
