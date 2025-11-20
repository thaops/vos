import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';

class CreateArticleUsecase {
  final NewsRepository repository;

  CreateArticleUsecase({required this.repository});

  Future<ApiResult<void>> call(News item) async {
    return await repository.createArticle(item);
  }
}
