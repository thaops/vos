import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';

class CheckViagsStatusUsecase {
  final ProfileRepository repository;

  CheckViagsStatusUsecase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getViagsStatus();
  }
}

