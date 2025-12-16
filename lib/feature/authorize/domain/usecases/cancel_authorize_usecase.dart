import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/domain/repositories/authorize_repository.dart';

class CancelAuthorizeUsecase {
  final AuthorizeRepository repository;

  CancelAuthorizeUsecase({required this.repository});

  Future<ApiResult<void>> call({
    required String token,
    required int authorizeId,
    required String fromDate,
    required String lsAuthorize,
  }) {
    return repository.cancelAuthorize(
      token: token,
      authorizeId: authorizeId,
      fromDate: fromDate,
      lsAuthorize: lsAuthorize,
    );
  }
}

