import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/feature/authorize_create/data/datasources/remote/authorize_create_remote_datasource.dart';
import 'package:vos_flutter/feature/authorize_create/data/repository_impl/authorize_create_repository_impl.dart';
import 'package:vos_flutter/feature/authorize_create/domain/repositories/authorize_create_repository.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/search_authorized_persons_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/load_authorize_types_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/load_authorize_statuses_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/create_authorize_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/controller/authorize_create_controller.dart';

class AuthorizeCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthorizeCreateRemoteDataSource>(
      () => AuthorizeCreateRemoteDataSourceImpl(
        dio: dioLib.Dio(),
      ),
    );

    Get.lazyPut<AuthorizeCreateRepository>(
      () => AuthorizeCreateRepositoryImpl(
        remoteDataSource: Get.find<AuthorizeCreateRemoteDataSource>(),
      ),
    );

    Get.lazyPut<SearchAuthorizedPersonsUsecase>(
      () => SearchAuthorizedPersonsUsecase(
        repository: Get.find<AuthorizeCreateRepository>(),
      ),
    );

    Get.lazyPut<LoadAuthorizeTypesUsecase>(
      () => LoadAuthorizeTypesUsecase(
        repository: Get.find<AuthorizeCreateRepository>(),
      ),
    );

    Get.lazyPut<LoadAuthorizeStatusesUsecase>(
      () => LoadAuthorizeStatusesUsecase(
        repository: Get.find<AuthorizeCreateRepository>(),
      ),
    );

    Get.lazyPut<CreateAuthorizeUsecase>(
      () => CreateAuthorizeUsecase(
        repository: Get.find<AuthorizeCreateRepository>(),
      ),
    );

    Get.lazyPut<AuthorizeCreateController>(
      () => AuthorizeCreateController(
        searchAuthorizedPersonsUsecase: Get.find<SearchAuthorizedPersonsUsecase>(),
        loadAuthorizeTypesUsecase: Get.find<LoadAuthorizeTypesUsecase>(),
        loadAuthorizeStatusesUsecase: Get.find<LoadAuthorizeStatusesUsecase>(),
        createAuthorizeUsecase: Get.find<CreateAuthorizeUsecase>(),
      ),
    );
  }
}
