import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';

class UpdateArticleUsecase {
  final NewsRepository repository;

  UpdateArticleUsecase({required this.repository});

  Future<ApiResult<bool>> call(News item) async {
    return await repository.updateArticle(item);
  }
}
