import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_cached_banners_usecase.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_banners_usecase.dart';
import 'package:vos_flutter/common/shared/auth/sign_out_clear.dart';

class BannerController extends GetxController {
  final GetBannersUsecase getBannersUsecase;
  final GetCachedBannersUsecase getCachedBannersUsecase;

  BannerController({
    required this.getBannersUsecase,
    required this.getCachedBannersUsecase,
  });

  final RxList<Banner> banners = <Banner>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Load banner từ cache persist (GetStorage) để vào Home hiển thị ngay.
  Future<void> loadCachedBanners(int recUserID) async {
    try {
      final result = await getCachedBannersUsecase.call(recUserID);
      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        if (banners.isEmpty) {
          banners.value = result.data!;
        }
      }
    } catch (_) {
      // Ignore cache errors
    }
  }

  /// Load banners từ API.
  ///
  /// - `silent`: refresh ngầm (không bật loader nếu đã có cache trên UI).
  /// - Khi đang có banner cache, nếu API fail sẽ **giữ nguyên cache** để UI mượt.
  Future<void> loadBanners(
    String token,
    int recUserID, {
    bool silent = false,
  }) async {
    try {
      final bool shouldShowLoading = !silent || banners.isEmpty;
      if (shouldShowLoading) {
        isLoading.value = true;
      }
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
          error.value =
              'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại tài khoản.';
          banners.clear();
          return;
        }

        error.value = errorMsg;
        // ✅ Ưu tiên cache: nếu đang có dữ liệu thì giữ nguyên, tránh UI nhấp nháy.
        if (banners.isEmpty) {
          banners.clear();
        }
      }
    } catch (e) {
      final errorMsg = e.toString();

      // Kiểm tra nếu token expired thì hủy liên kết để người dùng liên kết lại
      if (_isTokenExpiredError(errorMsg)) {
        print(
          '🔒 Token expired detected in banner exception, unlinking auth...',
        );
        await SignOutClear().unlinkViagsOnly();
        error.value =
            'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại tài khoản.';
        banners.clear();
        return;
      }

      error.value = 'Lỗi: $e';
      // ✅ Ưu tiên cache: nếu đang có dữ liệu thì giữ nguyên.
      if (banners.isEmpty) {
        banners.clear();
      }
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
