import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

abstract class NewsDetailRepository {
  Future<ApiResult<List<NewsDetail>>> getNews();

  Future<ApiResult<NewsDetail>> getArticleDetail(String id);

  Future<ApiResult<List<NewsDetail>>> searchNews(String query);

  Future<ApiResult<void>> createArticle(NewsDetail item);

  Future<ApiResult<bool>> updateArticle(NewsDetail item);

  Future<ApiResult<bool>> deleteArticle(String id);
}
