import 'package:get/get.dart';

import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/news/data/datasources/remote/news_remote_datasource.dart';

import 'package:vos_flutter/feature/news/data/datasources/local/news_local_datasource.dart';

import 'package:vos_flutter/feature/news/data/repository_impl/news_repository_impl.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';

import 'package:vos_flutter/feature/news/domain/usecases/get_news_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/get_article_detail_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/search_news_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/create_article_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/update_article_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/delete_article_usecase.dart';

import 'package:vos_flutter/feature/news/presentation/controller/news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    // Đăng ký DioApi nếu chưa có
    if (!Get.isRegistered<DioApi>()) {
      Get.lazyPut<DioApi>(() => DioApi());
    }

    Get.lazyPut<NewsRemoteDataSource>(
      () => NewsRemoteDataSourceImpl(dioApi: Get.find<DioApi>()),
    );

    Get.lazyPut<NewsLocalDataSource>(() => NewsLocalDataSourceImpl());

    Get.lazyPut<NewsRepository>(
      () => NewsRepositoryImpl(
        remoteDataSource: Get.find<NewsRemoteDataSource>(),
        localDataSource: Get.find<NewsLocalDataSource>(),
      ),
    );

    Get.lazyPut<GetNewsUsecase>(
      () => GetNewsUsecase(repository: Get.find<NewsRepository>()),
    );

    Get.lazyPut<GetArticleDetailUsecase>(
      () => GetArticleDetailUsecase(repository: Get.find<NewsRepository>()),
    );

    Get.lazyPut<SearchNewsUsecase>(
      () => SearchNewsUsecase(repository: Get.find<NewsRepository>()),
    );

    Get.lazyPut<CreateArticleUsecase>(
      () => CreateArticleUsecase(repository: Get.find<NewsRepository>()),
    );

    Get.lazyPut<UpdateArticleUsecase>(
      () => UpdateArticleUsecase(repository: Get.find<NewsRepository>()),
    );

    Get.lazyPut<DeleteArticleUsecase>(
      () => DeleteArticleUsecase(repository: Get.find<NewsRepository>()),
    );

    Get.lazyPut<NewsController>(
      () => NewsController(
        getNewsUsecase: Get.find<GetNewsUsecase>(),

        getArticleDetailUsecase: Get.find<GetArticleDetailUsecase>(),

        searchNewsUsecase: Get.find<SearchNewsUsecase>(),

        createArticleUsecase: Get.find<CreateArticleUsecase>(),

        updateArticleUsecase: Get.find<UpdateArticleUsecase>(),

        deleteArticleUsecase: Get.find<DeleteArticleUsecase>(),
      ),
    );
  }
}
