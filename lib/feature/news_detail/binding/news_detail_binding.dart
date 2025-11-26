import 'package:get/get.dart';

import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/feature/news_detail/data/datasources/remote/news_detail_remote_datasource.dart';

import 'package:vos_flutter/feature/news_detail/data/repository_impl/news_detail_repository_impl.dart';
import 'package:vos_flutter/feature/news_detail/domain/repositories/news_detail_repository.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/get_news_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/get_article_detail_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/search_news_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/create_article_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/update_article_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/delete_article_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/models/news_detail_args.dart';
import 'package:vos_flutter/feature/news_detail/presentation/controller/news_detail_controller.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class NewsDetailBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Parse arguments TẠI ĐÂY
    final args = Get.arguments as NewsDetailArgs?;

    // 2. Đảm bảo ProfileController được register trước
    if (!Get.isRegistered<ProfileController>()) {
      ProfileBinding().dependencies();
    }

    // 3. Đăng ký DioApi nếu chưa có
    if (!Get.isRegistered<DioApi>()) {
      Get.lazyPut<DioApi>(() => DioApi());
    }

    // 4. Data Sources
    Get.lazyPut<NewsDetailRemoteDataSource>(
      () => NewsDetailRemoteDataSourceImpl(dioApi: Get.find<DioApi>()),
    );

    Get.lazyPut<NewsDetailRepository>(
      () => NewsDetailRepositoryImpl(
        remoteDataSource: Get.find<NewsDetailRemoteDataSource>(),
      ),
    );

    Get.lazyPut<GetNewsDetailUsecase>(
      () => GetNewsDetailUsecase(repository: Get.find<NewsDetailRepository>()),
    );

    Get.lazyPut<GetNewsDetailArticleUsecase>(
      () => GetNewsDetailArticleUsecase(
        repository: Get.find<NewsDetailRepository>(),
      ),
    );

    Get.lazyPut<SearchNewsDetailUsecase>(
      () =>
          SearchNewsDetailUsecase(repository: Get.find<NewsDetailRepository>()),
    );

    Get.lazyPut<CreateNewsDetailArticleUsecase>(
      () => CreateNewsDetailArticleUsecase(
        repository: Get.find<NewsDetailRepository>(),
      ),
    );

    Get.lazyPut<UpdateNewsDetailArticleUsecase>(
      () => UpdateNewsDetailArticleUsecase(
        repository: Get.find<NewsDetailRepository>(),
      ),
    );

    Get.lazyPut<DeleteNewsDetailArticleUsecase>(
      () => DeleteNewsDetailArticleUsecase(
        repository: Get.find<NewsDetailRepository>(),
      ),
    );

    Get.lazyPut<NewsDetailController>(
      () => NewsDetailController(
        args: args,
        getNewsUsecase: Get.find<GetNewsDetailUsecase>(),
        getArticleDetailUsecase: Get.find<GetNewsDetailArticleUsecase>(),
        searchNewsUsecase: Get.find<SearchNewsDetailUsecase>(),
        createArticleUsecase: Get.find<CreateNewsDetailArticleUsecase>(),
        updateArticleUsecase: Get.find<UpdateNewsDetailArticleUsecase>(),
        deleteArticleUsecase: Get.find<DeleteNewsDetailArticleUsecase>(),
      ),
    );
  }
}
