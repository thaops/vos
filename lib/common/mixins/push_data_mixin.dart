import 'package:get/get.dart';
import 'package:vos_flutter/common/constants/http_status_codes.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/widgets/custom_snackbar.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';

mixin PushDataMixin<T> on BaseController {
  final _data = Rxn<T>();
  T? get data => _data.value;

  Future<void> pushData();

  void setData(T? newData) {
    _data.value = newData;
  }

  /// Hàm cũ - giữ lại để backward compatible
  Future<void> postData({
    required Future<dynamic> Function() apiCall,
    required Function(dynamic) onSuccess,
    Function(dynamic)? onError,
  }) async {
    if (status == ControllerStatus.loading) return;
    try {
      setStatus(ControllerStatus.loading);
      final response = await apiCall();
      if (response.data['statusCode'] != HttpStatusCodes.STATUS_CODE_OK) {
        final error = response.data['message'] ?? '';
        setStatus(ControllerStatus.error, error: error);
        CustomSnackbar.show(error);
        return;
      }
      onSuccess(response.data['data']);
    } catch (e) {
      onError?.call(e) ??
          setStatus(ControllerStatus.error, error: e.toString());
      print("Error Call APi: $e");
    }
  }

  /// Hàm mới - sử dụng ApiResult (khuyến nghị dùng)
  /// Push data với ApiResult từ repository
  Future<T?> pushWithApiResult({
    required Future<ApiResult<T>> Function() apiCall,
    bool showErrorSnackbar = true,
    Function(T)? onSuccess,
    Function(String)? onError,
  }) async {
    if (this is ApiResultMixin) {
      return await (this as ApiResultMixin).handleApiCall<T>(
        apiCall: apiCall,
        showErrorSnackbar: showErrorSnackbar,
        onSuccess: (data) {
          setData(data);
          setStatus(ControllerStatus.success);
          onSuccess?.call(data);
        },
        onError: onError,
      );
    } else {
      // Fallback nếu không có ApiResultMixin
      if (status == ControllerStatus.loading) return null;
      try {
        setStatus(ControllerStatus.loading);
        final result = await apiCall();
        if (result.isSuccess && result.data != null) {
          setData(result.data!);
          setStatus(ControllerStatus.success);
          onSuccess?.call(result.data!);
          return result.data;
        } else {
          final errorMsg = result.error ?? 'Có lỗi xảy ra';
          setStatus(ControllerStatus.error, error: errorMsg);
          if (showErrorSnackbar) {
            CustomSnackbar.show(errorMsg);
          }
          onError?.call(errorMsg);
          return null;
        }
      } catch (e) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        setStatus(ControllerStatus.error, error: errorMsg);
        if (showErrorSnackbar) {
          CustomSnackbar.show(errorMsg);
        }
        onError?.call(errorMsg);
        return null;
      }
    }
  }
}
