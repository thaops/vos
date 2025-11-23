import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';

class CheckEmployeeStatusUsecase {
  final ProfileRepository repository;

  CheckEmployeeStatusUsecase(this.repository);

  Future<bool> call() async {
    return await repository.getEmployeeStatus();
  }
}

