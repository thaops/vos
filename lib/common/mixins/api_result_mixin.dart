import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/widgets/custom_snackbar.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/shared/auth/sign_out_clear.dart';

/// Mixin để xử lý API call trả về ApiResult một cách thống nhất
mixin ApiResultMixin on BaseController {
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

        if (result.data != null) {
          onSuccess?.call(result.data!);
          return result.data;
        } else {
          onSuccess?.call(null as T);
          return null;
        }
      } else {
        final errorMsg = result.error ?? 'Có lỗi xảy ra';

        if (_isTokenExpiredError(errorMsg)) {
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

      if (_isTokenExpiredError(errorMsg)) {
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

        if (_isTokenExpiredError(errorMsg)) {
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

      if (_isTokenExpiredError(errorMsg)) {
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

  bool _isTokenExpiredError(String? errorMsg) {
    if (errorMsg == null || errorMsg.isEmpty) return false;
    final lowerError = errorMsg.toLowerCase();
    return lowerError.contains('token expired') ||
        lowerError.contains('token hết hạn') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('token invalid');
  }

  Future<void> _handleTokenExpired() async {
    await SignOutClear().unlinkViagsOnly();
    setStatus(
      ControllerStatus.error,
      error: 'Phiên đăng nhập đã hết hạn, vui lòng liên kết lại.',
    );
    CustomSnackbar.show('Phiên đăng nhập đã hết hạn, vui lòng liên kết lại.');
  }
}
