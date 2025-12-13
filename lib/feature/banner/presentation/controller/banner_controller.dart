import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_banners_usecase.dart';
import 'package:vos_flutter/common/shared/auth/sign_out_clear.dart';

class BannerController extends GetxController {
  final GetBannersUsecase getBannersUsecase;

  BannerController({required this.getBannersUsecase});

  final RxList<Banner> banners = <Banner>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadBanners(String token, int recUserID) async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await getBannersUsecase.call(token, recUserID);

      if (result.isSuccess && result.data != null) {
        banners.value = result.data!;
      } else {
        final errorMsg = result.error ?? 'Không thể tải banner';
        
        // Kiểm tra nếu token expired thì hủy liên kết để người dùng liên kết lại
        if (_isTokenExpiredError(errorMsg)) {
          print('🔒 Token expired detected in banner, unlinking auth...');
          await SignOutClear().unlinkViagsOnly();
          error.value = 'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại tài khoản.';
          return;
        }
        
        error.value = errorMsg;
        banners.clear();
      }
    } catch (e) {
      final errorMsg = e.toString();
      
      // Kiểm tra nếu token expired thì hủy liên kết để người dùng liên kết lại
      if (_isTokenExpiredError(errorMsg)) {
        print('🔒 Token expired detected in banner exception, unlinking auth...');
        await SignOutClear().unlinkViagsOnly();
        error.value = 'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại tài khoản.';
        return;
      }
      
      error.value = 'Lỗi: $e';
      banners.clear();
    } finally {
      isLoading.value = false;
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