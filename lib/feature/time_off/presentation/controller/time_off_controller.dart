import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_list_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';

class TimeOffController extends BaseController with ApiResultMixin {
  final GetTimeOffListUsecase getTimeOffListUsecase;
  final UpdateTimeOffUsecase updateTimeOffUsecase;

  final RxList<TimeOff> timeOffList = <TimeOff>[].obs;

  TimeOffController({
    required this.getTimeOffListUsecase,
    required this.updateTimeOffUsecase,
  });

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
      _cancelTimeOff(timeOff);
    }
  }

void _cancelTimeOff(TimeOff timeOff) async {
  final request = TimeOffCreateRequest(
    vRegId: timeOff.vRegId,
    fromDate: timeOff.fromDate ?? DateTime.now(), 
    domInt: timeOff.domInt ?? '', 
    description: timeOff.description ?? '', 
    vacationReason: timeOff.vacationReason ?? '', 
    contactPerson: timeOff.contactPerson ?? '', 
    contactInfor: timeOff.contactInfor ?? '', 
    status: 'XX', 
    recUserID: timeOff.hrId ?? 0, 
    lsDetail: timeOff.details?.map((detail) => WorkCodeDetail(
      jobCode: detail.jobCode,
      soLuong: detail.soLuong,
    )).toList() ?? [], 
  );

  await handleApiCall<void>(
    apiCall: () => updateTimeOffUsecase.call(request),
    onSuccess: (id) {
      loadTimeOffList();
    },
  );
}
}
