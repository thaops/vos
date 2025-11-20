import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

class GetNewsDetailArticleUsecase {
  final NewsDetailRepository repository;

  GetNewsDetailArticleUsecase({required this.repository});

  Future<ApiResult<NewsDetail>> call(String id) async {
    return await repository.getArticleDetail(id);
  }
}
