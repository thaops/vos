import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

class UpdateNewsDetailArticleUsecase {
  final NewsDetailRepository repository;

  UpdateNewsDetailArticleUsecase({required this.repository});

  Future<ApiResult<bool>> call(NewsDetail item) async {
    return await repository.updateArticle(item);
  }
}
