import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';

class DeleteArticleUsecase {
  final NewsRepository repository;

  DeleteArticleUsecase({required this.repository});

  Future<ApiResult<bool>> call(String id) async {
    return await repository.deleteArticle(id);
  }
}
