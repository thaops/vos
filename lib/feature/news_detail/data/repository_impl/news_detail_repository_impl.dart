import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news_detail/data/models/news_detail_dto.dart';

import 'package:vos_flutter/feature/news_detail/data/datasources/remote/news_detail_remote_datasource.dart';

import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';

class NewsDetailRepositoryImpl implements NewsDetailRepository {
  final NewsDetailRemoteDataSource remoteDataSource;

  NewsDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<NewsDetail>>> getNews() async {
    final result = await remoteDataSource.getNews();

    return result;
  }

  @override
  Future<ApiResult<NewsDetail>> getArticleDetail(String id) async {
    final result = await remoteDataSource.getArticleDetail(id);

    return result;
  }

  @override
  Future<ApiResult<List<NewsDetail>>> searchNews(String query) async {
    final result = await remoteDataSource.searchNews(query);

    return result;
  }

  @override
  Future<ApiResult<void>> createArticle(NewsDetail item) async {
    final dto = NewsDetailDto.fromDomain(item);
    final result = await remoteDataSource.createArticle(dto);

    return result;
  }

  @override
  Future<ApiResult<bool>> updateArticle(NewsDetail item) async {
    final dto = NewsDetailDto.fromDomain(item);
    final result = await remoteDataSource.updateArticle(dto);

    return result;
  }

  @override
  Future<ApiResult<bool>> deleteArticle(String id) async {
    final result = await remoteDataSource.deleteArticle(id);

    return result;
  }
}
