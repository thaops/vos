import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/widgets/custom_snackbar.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/shared/auth/sign_out_clear.dart';

/// Mixin để xử lý API call trả về ApiResult một cách thống nhất
mixin ApiResultMixin on BaseController {
  /// Generic handler cho API call trả về ApiResult
  ///
  /// [apiCall]: Function trả về Future<ApiResult<T>>
  /// [showErrorSnackbar]: Có hiển thị snackbar khi lỗi không (mặc định: true)
  /// [onSuccess]: Callback khi API thành công
  /// [onError]: Callback khi API lỗi (optional, nếu không có sẽ dùng snackbar mặc định)
  ///
  /// Returns: Data nếu thành công, null nếu lỗi
  Future<T?> handleApiCall<T>({
    required Future<ApiResult<T>> Function() apiCall,
    bool showErrorSnackbar = true,
    Function(T)? onSuccess,
    Function(String)? onError,
  }) async {
    if (status == ControllerStatus.loading) return null;

    try {
      setStatus(ControllerStatus.loading);
      final result = await apiCall();

      if (result.isSuccess) {
        setStatus(ControllerStatus.success);
        // Với void type, result.data sẽ là null, nhưng vẫn là success
        // Gọi onSuccess bất kể có data hay không (void type không cần data)
        if (result.data != null) {
          onSuccess?.call(result.data!);
          return result.data;
        } else {
          // Với void type, vẫn là success nhưng không có data
          // Gọi onSuccess với null (sẽ được cast về void)
          print('✅ [ApiResultMixin] Success with void type, calling onSuccess');
          onSuccess?.call(null as T);
          return null;
        }
      } else {
        print('❌ [ApiResultMixin] API call failed: ${result.error}');
        final errorMsg = result.error ?? 'Có lỗi xảy ra';

        // Kiểm tra nếu token expired thì tự động đăng xuất
        if (_isTokenExpiredError(errorMsg)) {
          print('🔒 Token expired detected, unlinking auth...');
          await _handleTokenExpired();
          return null;
        }

        setStatus(ControllerStatus.error, error: errorMsg);
        if (showErrorSnackbar) {
          CustomSnackbar.show(errorMsg);
        }
        onError?.call(errorMsg);
        return null;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      // Kiểm tra nếu token expired thì tự động đăng xuất
      if (_isTokenExpiredError(errorMsg)) {
        print('🔒 Token expired detected in exception, unlinking auth...');
        await _handleTokenExpired();
        return null;
      }

      setStatus(ControllerStatus.error, error: errorMsg);
      if (showErrorSnackbar) {
        CustomSnackbar.show(errorMsg);
      }
      onError?.call(errorMsg);
      return null;
    }
  }

  /// Handler cho API call không cần trả về data (chỉ cần biết success/error)
  Future<bool> handleApiCallVoid({
    required Future<ApiResult<void>> Function() apiCall,
    bool showErrorSnackbar = true,
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    if (status == ControllerStatus.loading) return false;

    try {
      setStatus(ControllerStatus.loading);
      final result = await apiCall();

      if (result.isSuccess) {
        setStatus(ControllerStatus.success);
        onSuccess?.call();
        return true;
      } else {
        final errorMsg = result.error ?? 'Có lỗi xảy ra';

        // Kiểm tra nếu token expired thì tự động đăng xuất
        if (_isTokenExpiredError(errorMsg)) {
          print('🔒 Token expired detected, unlinking auth...');
          await _handleTokenExpired();
          return false;
        }

        setStatus(ControllerStatus.error, error: errorMsg);
        if (showErrorSnackbar) {
          CustomSnackbar.show(errorMsg);
        }
        onError?.call(errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      // Kiểm tra nếu token expired thì tự động đăng xuất
      if (_isTokenExpiredError(errorMsg)) {
        print('🔒 Token expired detected in exception, unlinking auth...');
        await _handleTokenExpired();
        return false;
      }

      setStatus(ControllerStatus.error, error: errorMsg);
      if (showErrorSnackbar) {
        CustomSnackbar.show(errorMsg);
      }
      onError?.call(errorMsg);
      return false;
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

  Future<void> _handleTokenExpired() async {
    // Hủy liên kết để người dùng tự liên kết lại, không sign out toàn bộ
    await SignOutClear().unlinkAuth();
    setStatus(ControllerStatus.error,
        error: 'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại.');
    CustomSnackbar.show('Phiên đăng nhập đã hết hạn, vui lòng liên kết lại.');
  }
}
