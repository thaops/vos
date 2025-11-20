import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';

class GetArticleDetailUsecase {
  final NewsRepository repository;

  GetArticleDetailUsecase({required this.repository});

  Future<ApiResult<News>> call(String id) async {
    return await repository.getArticleDetail(id);
  }
}
