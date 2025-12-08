import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/news/data/models/news_dto.dart';

import 'package:vos_flutter/feature/news/data/datasources/remote/news_remote_datasource.dart';

import 'package:vos_flutter/feature/news/data/datasources/local/news_local_datasource.dart';

import 'package:vos_flutter/feature/news/domain/models/news.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,

    required this.localDataSource,
  });

  @override
  Future<ApiResult<List<News>>> getNews({
    int page = 1,
    int limit = 10,
    String keyword = '',
  }) async {
    final remoteResult = await remoteDataSource.getNews(
      page: page,
      limit: limit,
      keyword: keyword,
    );

    if (remoteResult.isSuccess && remoteResult.data != null) {
      final dtoList = remoteResult.data!
          .map((news) => NewsDto.fromDomain(news))
          .toList();
      await localDataSource.saveNewsPage(page, dtoList);
      return remoteResult;
    }

    try {
      final localData = await localDataSource.getNewsPage(page);
      if (localData != null && localData.isNotEmpty) {
        final domainList = localData.map((dto) => dto.toDomain()).toList();
        return ApiResult.success(domainList);
      }
    } catch (e) {
      print('Error getting news from local: $e');
    }

    return remoteResult;
  }

  @override
  Future<ApiResult<News>> getArticleDetail(String id) async {
    final remoteResult = await remoteDataSource.getArticleDetail(id);

    if (remoteResult.isSuccess && remoteResult.data != null && id.isNotEmpty) {
      await localDataSource.saveNews(NewsDto.fromDomain(remoteResult.data!));
      return remoteResult;
    }

    try {
      final localData = await localDataSource.getNews(id);
      if (localData != null) {
        return ApiResult.success(localData.toDomain());
      }
    } catch (e) {
      print('Error getting article detail from local: $e');
    }

    return remoteResult;
  }

  @override
  Future<ApiResult<List<News>>> searchNews(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    final remoteResult = await remoteDataSource.searchNews(
      query,
      page: page,
      limit: limit,
    );

    if (remoteResult.isSuccess && remoteResult.data != null) {
      final dtoList = remoteResult.data!
          .map((news) => NewsDto.fromDomain(news))
          .toList();
      await localDataSource.saveNewsPage(page, dtoList);
      return remoteResult;
    }

    try {
      final allLocalNews = await localDataSource.getNewsList();
      if (allLocalNews.isNotEmpty) {
        final filtered = allLocalNews
            .where((dto) {
              final title = dto.title?.toLowerCase() ?? '';
              final description = dto.description?.toLowerCase() ?? '';
              final queryLower = query.toLowerCase();
              return title.contains(queryLower) ||
                  description.contains(queryLower);
            })
            .map((dto) => dto.toDomain())
            .toList();

        if (filtered.isNotEmpty) {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          final paginatedList = filtered.length > startIndex
              ? filtered.sublist(
                  startIndex,
                  endIndex > filtered.length ? filtered.length : endIndex,
                )
              : <News>[];

          return ApiResult.success(paginatedList);
        }
      }
    } catch (e) {}

    return remoteResult;
  }

  @override
  Future<ApiResult<void>> createArticle(News item) async {
    final dto = NewsDto.fromDomain(item);
    final result = await remoteDataSource.createArticle(dto);

    if (result.isSuccess) {
      await localDataSource.saveNews(dto);
    }

    return result;
  }

  @override
  Future<ApiResult<bool>> updateArticle(News item) async {
    final dto = NewsDto.fromDomain(item);
    final result = await remoteDataSource.updateArticle(dto);

    if (result.isSuccess) {
      await localDataSource.saveNews(dto);
    }

    return result;
  }

  @override
  Future<ApiResult<bool>> deleteArticle(String id) async {
    final result = await remoteDataSource.deleteArticle(id);

    if (result.isSuccess) {
      await localDataSource.clearNews(id);
    }

    return result;
  }
}
