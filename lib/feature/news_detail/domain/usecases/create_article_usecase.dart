import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

class CreateNewsDetailArticleUsecase {
  final NewsDetailRepository repository;

  CreateNewsDetailArticleUsecase({required this.repository});

  Future<ApiResult<void>> call(NewsDetail item) async {
    return await repository.createArticle(item);
  }
}
