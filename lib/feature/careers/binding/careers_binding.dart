import 'package:get/get.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/news/data/datasources/remote/news_remote_datasource.dart';
import 'package:vos_flutter/feature/news/data/datasources/local/news_local_datasource.dart';
import 'package:vos_flutter/feature/news/data/repository_impl/news_repository_impl.dart';
import 'package:vos_flutter/feature/news/domain/repositories/news_repository.dart';
import 'package:vos_flutter/feature/news/domain/usecases/get_news_usecase.dart';
import 'package:vos_flutter/feature/news/domain/usecases/get_article_detail_usecase.dart';
import 'package:vos_flutter/feature/news/domain/usecases/search_news_usecase.dart';
import 'package:vos_flutter/feature/careers/presentation/controller/careers_controller.dart';

class CareersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DioApi>()) {
      Get.lazyPut<DioApi>(() => DioApi());
    }

    if (!Get.isRegistered<NewsRemoteDataSource>()) {
      Get.lazyPut<NewsRemoteDataSource>(
        () => NewsRemoteDataSourceImpl(dioApi: Get.find<DioApi>()),
      );
    }

    if (!Get.isRegistered<NewsLocalDataSource>()) {
      Get.lazyPut<NewsLocalDataSource>(() => NewsLocalDataSourceImpl());
    }

    if (!Get.isRegistered<NewsRepository>()) {
      Get.lazyPut<NewsRepository>(
        () => NewsRepositoryImpl(
          remoteDataSource: Get.find<NewsRemoteDataSource>(),
          localDataSource: Get.find<NewsLocalDataSource>(),
        ),
      );
    }

    if (!Get.isRegistered<GetNewsUsecase>()) {
      Get.lazyPut<GetNewsUsecase>(
        () => GetNewsUsecase(repository: Get.find<NewsRepository>()),
      );
    }

    if (!Get.isRegistered<GetArticleDetailUsecase>()) {
      Get.lazyPut<GetArticleDetailUsecase>(
        () => GetArticleDetailUsecase(repository: Get.find<NewsRepository>()),
      );
    }

    if (!Get.isRegistered<SearchNewsUsecase>()) {
      Get.lazyPut<SearchNewsUsecase>(
        () => SearchNewsUsecase(repository: Get.find<NewsRepository>()),
      );
    }

    Get.lazyPut<CareersController>(
      () => CareersController(
        getNewsUsecase: Get.find<GetNewsUsecase>(),
        getArticleDetailUsecase: Get.find<GetArticleDetailUsecase>(),
        searchNewsUsecase: Get.find<SearchNewsUsecase>(),
      ),
    );
  }
}

