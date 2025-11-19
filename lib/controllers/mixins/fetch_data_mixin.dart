import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:vos_flutter/common/constants/http_status_codes.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/widgets/custom_snackbar.dart';
import 'package:vos_flutter/controllers/base/base_controller.dart';
import 'package:vos_flutter/controllers/mixins/api_result_mixin.dart';
import 'package:dio/dio.dart';

mixin FetchDataMixin<T> on BaseController {
  final _data = Rxn<T>();
  T? get data => _data.value;

  Future<void> fetchData();

  void setData(T? newData) {
    _data.value = newData;
  }

  Future<void> refreshData() async {
    if (status == ControllerStatus.refreshing) return;
    setStatus(ControllerStatus.refreshing);
    await fetchData();
  }

  /// Hàm cũ - giữ lại để backward compatible
  Future<void> fetchApiData({
    required Future<dynamic> Function() apiCall,
    required Function(dynamic) onSuccess,
    Function(dynamic)? onError,
  }) async {
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
    }
  }

  /// Hàm mới - sử dụng ApiResult (khuyến nghị dùng)
  /// Fetch data với ApiResult từ repository
  Future<void> fetchWithApiResult({
    required Future<ApiResult<T>> Function() apiCall,
    bool showErrorSnackbar = true,
    Function(T)? onSuccess,
  }) async {
    if (this is ApiResultMixin) {
      await (this as ApiResultMixin).handleApiCall<T>(
        apiCall: apiCall,
        showErrorSnackbar: showErrorSnackbar,
        onSuccess: (data) {
          setData(data);
          setStatus(ControllerStatus.success);
          onSuccess?.call(data);
        },
      );
    } else {
      // Fallback nếu không có ApiResultMixin
      try {
        setStatus(ControllerStatus.loading);
        final result = await apiCall();
        if (result.isSuccess && result.data != null) {
          setData(result.data!);
          setStatus(ControllerStatus.success);
          onSuccess?.call(result.data!);
        } else {
          final errorMsg = result.error ?? 'Có lỗi xảy ra';
          setStatus(ControllerStatus.error, error: errorMsg);
          if (showErrorSnackbar) {
            CustomSnackbar.show(errorMsg);
          }
        }
      } catch (e) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        setStatus(ControllerStatus.error, error: errorMsg);
        if (showErrorSnackbar) {
          CustomSnackbar.show(errorMsg);
        }
      }
    }
  }
}

extension FetchHelper on FetchDataMixin {
  Future<void> fetchListModel<T>({
    required Future<Response<dynamic>> Function() apiCall,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    await fetchApiData(
      apiCall: apiCall,
      onSuccess: (data) {
        final list = (data as List).map((e) => fromJson(e)).toList();
        setData(list);
        setStatus(
          list.isEmpty ? ControllerStatus.empty : ControllerStatus.success,
        );
      },
    );
  }
}
