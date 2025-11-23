import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/feature/authorize/data/datasources/remote/authorize_remote_datasource.dart';
import 'package:vos_flutter/feature/authorize/data/repository_impl/authorize_repository_impl.dart';
import 'package:vos_flutter/feature/authorize/domain/repositories/authorize_repository.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/get_authorizes_usecase.dart';
import 'package:vos_flutter/feature/authorize/presentation/controller/authorize_controller.dart';

class AuthorizeBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<AuthorizeRemoteDataSource>(
      () => AuthorizeRemoteDataSourceImpl(
        dio: dioLib.Dio(),
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

    // Controller
    Get.lazyPut<AuthorizeController>(
      () => AuthorizeController(
        getAuthorizesUsecase: Get.find<GetAuthorizesUsecase>(),
      ),
    );
  }
}

