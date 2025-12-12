import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/vacation/data/datasources/remote/vacation_remote_datasource.dart';
import 'package:vos_flutter/feature/vacation/data/repository_impl/vacation_repository_impl.dart';
import 'package:vos_flutter/feature/vacation/domain/repositories/vacation_repository.dart';
import 'package:vos_flutter/feature/vacation/domain/usecases/get_vacation_list_usecase.dart';
import 'package:vos_flutter/feature/vacation/presentation/controller/vacation_controller.dart';

class VacationBinding extends Bindings {
  @override
  void dependencies() {
    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Data Source
    Get.lazyPut<VacationRemoteDataSource>(
      () => VacationRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    // Repository
    Get.lazyPut<VacationRepository>(
      () => VacationRepositoryImpl(
        remoteDataSource: Get.find<VacationRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetVacationListUsecase>(
      () => GetVacationListUsecase(
        repository: Get.find<VacationRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<VacationController>(
      () => VacationController(
        getVacationListUsecase: Get.find<GetVacationListUsecase>(),
      ),
    );
  }
}

