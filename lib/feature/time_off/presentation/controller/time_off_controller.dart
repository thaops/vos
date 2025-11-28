import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_list_usecase.dart';

class TimeOffController extends BaseController with ApiResultMixin {
  final GetTimeOffListUsecase getTimeOffListUsecase;

  final RxList<TimeOff> timeOffList = <TimeOff>[].obs;

  TimeOffController({required this.getTimeOffListUsecase});

  @override
  void onInit() {
    super.onInit();
    loadTimeOffList();
  }

  Future<void> loadTimeOffList() async {
    // Token được tự động lấy trong DataSource, không cần truyền nữa
    await handleApiCall<List<TimeOff>>(
      apiCall: () => getTimeOffListUsecase.call(vRegId: 0, year: 0),
      onSuccess: (data) {
        timeOffList.assignAll(data);
      },
    );
  }

  Future<void> onRefresh() async {
    await loadTimeOffList();
  }

  Future<void> cancelTimeOff(TimeOff timeOff) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn nghỉ phép này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement cancel API call
      // final profile = profileController;
      // if (profile != null && profile.userProfile.value != null) {
      //   final token = profile.userProfile.value?.token ?? '';
      //   await cancelTimeOffUsecase.call(token: token, vRegId: timeOff.vRegId);
      //   await loadTimeOffList(); // Reload list
      // }
      Get.snackbar(
        'Thông báo',
        'Chức năng hủy đơn đang được phát triển',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
