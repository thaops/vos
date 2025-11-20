import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';

class GetNewsDetailUsecase {
  final NewsDetailRepository repository;

  GetNewsDetailUsecase({required this.repository});

  Future<ApiResult<List<NewsDetail>>> call() async {
    return await repository.getNews();
  }
}
