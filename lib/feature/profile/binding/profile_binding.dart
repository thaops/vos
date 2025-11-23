import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:vos_flutter/feature/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:vos_flutter/feature/profile/data/repository_impl/profile_repository_impl.dart';
import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/check_employee_status_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/check_viags_status_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/link_viags_account_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/logout_usecase.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        dio: dioLib.Dio(),
      ),
    );

    Get.lazyPut<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(),
    );

    // Repository
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: Get.find<ProfileRemoteDataSource>(),
        localDataSource: Get.find<ProfileLocalDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut<GetUserProfileUsecase>(
      () => GetUserProfileUsecase(
        Get.find<ProfileRepository>(),
      ),
    );

    Get.lazyPut<LinkViagsAccountUsecase>(
      () => LinkViagsAccountUsecase(
        Get.find<ProfileRepository>(),
      ),
    );

    Get.lazyPut<LogoutUsecase>(
      () => LogoutUsecase(
        Get.find<ProfileRepository>(),
      ),
    );

    Get.lazyPut<CheckViagsStatusUsecase>(
      () => CheckViagsStatusUsecase(
        Get.find<ProfileRepository>(),
      ),
    );

    Get.lazyPut<CheckEmployeeStatusUsecase>(
      () => CheckEmployeeStatusUsecase(
        Get.find<ProfileRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        getUserProfileUsecase: Get.find<GetUserProfileUsecase>(),
        linkViagsAccountUsecase: Get.find<LinkViagsAccountUsecase>(),
        logoutUsecase: Get.find<LogoutUsecase>(),
        checkViagsStatusUsecase: Get.find<CheckViagsStatusUsecase>(),
        checkEmployeeStatusUsecase: Get.find<CheckEmployeeStatusUsecase>(),
      ),
    );
  }
}
