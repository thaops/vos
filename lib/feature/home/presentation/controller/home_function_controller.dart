import 'package:get/get.dart';
import 'package:vos_flutter/feature/home/domain/models/home_function.dart';
import 'package:vos_flutter/feature/home/domain/usecases/get_home_functions_usecase.dart';
import 'package:vos_flutter/common/shared/auth/sign_out_clear.dart';

class HomeFunctionController extends GetxController {
  final GetHomeFunctionsUsecase getHomeFunctionsUsecase;

  HomeFunctionController({required this.getHomeFunctionsUsecase});

  final RxList<HomeFunctionSession> sessions = <HomeFunctionSession>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadHomeFunctions(String token, String lsStatus) async {
    try {
      print('🔄 Loading home functions with token: ${token.substring(0, token.length > 20 ? 20 : token.length)}..., lsStatus: $lsStatus');
      isLoading.value = true;
      error.value = '';

      final result = await getHomeFunctionsUsecase.call(token, lsStatus);

      if (result.isSuccess && result.data != null) {
        print('✅ Loaded ${result.data!.length} home function sessions');
        sessions.value = result.data!;
        print('✅ Sessions list updated: ${sessions.length} items');
      } else {
        final errorMsg = result.error ?? 'Không thể tải danh sách chức năng';
        print('❌ Load home functions failed: $errorMsg');
        
        // Kiểm tra nếu token expired thì hủy liên kết để người dùng liên kết lại
        if (_isTokenExpiredError(errorMsg)) {
          print('🔒 Token expired detected in home functions, unlinking auth...');
          await SignOutClear().unlinkAuth();
          error.value = 'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại tài khoản.';
          return;
        }
        
        error.value = errorMsg;
        sessions.clear();
      }
    } catch (e) {
      final errorMsg = e.toString();
      print('❌ Load home functions exception: $e');
      
      // Kiểm tra nếu token expired thì hủy liên kết để người dùng liên kết lại
      if (_isTokenExpiredError(errorMsg)) {
        print('🔒 Token expired detected in home functions exception, unlinking auth...');
        await SignOutClear().unlinkAuth();
        error.value = 'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại tài khoản.';
        return;
      }
      
      error.value = 'Lỗi: $e';
      sessions.clear();
    } finally {
      isLoading.value = false;
      print('🔄 Home functions loading completed. isLoading: ${isLoading.value}, sessions: ${sessions.length}');
    }
  }

  /// Kiểm tra xem error message có phải là token expired không
  bool _isTokenExpiredError(String? errorMsg) {
    if (errorMsg == null || errorMsg.isEmpty) return false;
    final lowerError = errorMsg.toLowerCase();
    return lowerError.contains('token expired') ||
        lowerError.contains('token hết hạn') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('token invalid');
  }
}

