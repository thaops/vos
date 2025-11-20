import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';

class SearchNewsUsecase {
  final NewsRepository repository;

  SearchNewsUsecase({required this.repository});

  Future<ApiResult<List<News>>> call(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.searchNews(query, page: page, limit: limit);
  }
}
