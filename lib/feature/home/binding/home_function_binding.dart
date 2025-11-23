import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/feature/home/data/datasources/remote/home_function_remote_datasource.dart';
import 'package:vos_flutter/feature/home/data/repository_impl/home_function_repository_impl.dart';
import 'package:vos_flutter/feature/home/domain/repositories/home_function_repository.dart';
import 'package:vos_flutter/feature/home/domain/usecases/get_home_functions_usecase.dart';
import 'package:vos_flutter/feature/home/presentation/controller/home_function_controller.dart';

class HomeFunctionBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<HomeFunctionRemoteDataSource>(
      () => HomeFunctionRemoteDataSourceImpl(
        dio: dioLib.Dio(),
      ),
    );

    // Repository
    Get.lazyPut<HomeFunctionRepository>(
      () => HomeFunctionRepositoryImpl(
        remoteDataSource: Get.find<HomeFunctionRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetHomeFunctionsUsecase>(
      () => GetHomeFunctionsUsecase(
        Get.find<HomeFunctionRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<HomeFunctionController>(
      () => HomeFunctionController(
        getHomeFunctionsUsecase: Get.find<GetHomeFunctionsUsecase>(),
      ),
    );
  }
}

