import 'package:get/get.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/get_authorizes_usecase.dart';

class AuthorizeController extends GetxController {
  final GetAuthorizesUsecase getAuthorizesUsecase;

  AuthorizeController({required this.getAuthorizesUsecase});

  final RxList<Authorize> authorizes = <Authorize>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadAuthorizes(String token, int authorizeId, int hrId, int year) async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await getAuthorizesUsecase.call(token, authorizeId, hrId, year);

      if (result.isSuccess && result.data != null) {
        authorizes.value = result.data!;
      } else {
        error.value = result.error ?? 'Không thể tải danh sách ủy quyền';
        authorizes.clear();
      }
    } catch (e) {
      error.value = 'Lỗi: $e';
      authorizes.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

