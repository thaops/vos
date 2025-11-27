import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';

class DeleteNewsDetailArticleUsecase {
  final NewsDetailRepository repository;

  DeleteNewsDetailArticleUsecase({required this.repository});

  Future<ApiResult<bool>> call(String id) async {
    return await repository.deleteArticle(id);
  }
}
