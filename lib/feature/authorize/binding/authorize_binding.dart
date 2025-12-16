import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/authorize/data/datasources/remote/authorize_remote_datasource.dart';
import 'package:vos_flutter/feature/authorize/data/repository_impl/authorize_repository_impl.dart';
import 'package:vos_flutter/feature/authorize/domain/repositories/authorize_repository.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/get_authorizes_usecase.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/cancel_authorize_usecase.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/get_authorize_statuses_usecase.dart';
import 'package:vos_flutter/feature/authorize/presentation/controller/authorize_controller.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class AuthorizeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      ProfileBinding().dependencies();
    }

    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Data Source
    Get.lazyPut<AuthorizeRemoteDataSource>(
      () => AuthorizeRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    // Repository
    Get.lazyPut<AuthorizeRepository>(
      () => AuthorizeRepositoryImpl(
        remoteDataSource: Get.find<AuthorizeRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetAuthorizesUsecase>(
      () => GetAuthorizesUsecase(
        repository: Get.find<AuthorizeRepository>(),
      ),
    );
    Get.lazyPut<GetAuthorizeStatusesUsecase>(
      () => GetAuthorizeStatusesUsecase(
        repository: Get.find<AuthorizeRepository>(),
      ),
    );
    Get.lazyPut<CancelAuthorizeUsecase>(
      () => CancelAuthorizeUsecase(
        repository: Get.find<AuthorizeRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<AuthorizeController>(
      () => AuthorizeController(
        getAuthorizesUsecase: Get.find<GetAuthorizesUsecase>(),
        getAuthorizeStatusesUsecase: Get.find<GetAuthorizeStatusesUsecase>(),
        cancelAuthorizeUsecase: Get.find<CancelAuthorizeUsecase>(),
        profileController: Get.find<ProfileController>(),
      ),
    );
  }
}

