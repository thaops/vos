import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';

class SearchNewsDetailUsecase {
  final NewsDetailRepository repository;

  SearchNewsDetailUsecase({required this.repository});

  Future<ApiResult<List<NewsDetail>>> call(String query) async {
    return await repository.searchNews(query);
  }
}
