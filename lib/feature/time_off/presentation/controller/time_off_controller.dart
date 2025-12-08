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
  final RxList<TimeOff> allTimeOffList = <TimeOff>[].obs; // List gốc từ API
  final RxString selectedStatusFilter =
      'Tất cả'.obs; // Filter trạng thái (name để hiển thị)
  final RxString selectedStatusCode =
      'ALL'.obs; // Filter trạng thái (code để lọc)
  final RxInt selectedYear = DateTime.now().year.obs; // Filter năm

  // Danh sách filter trạng thái (set cứng)
  static const List<Map<String, String>> statusFilterList = [
    {'code': 'ALL', 'name': 'Tất cả'},
    {'code': 'OK', 'name': 'Đang sử dụng'},
    {'code': 'XX', 'name': 'Đánh dấu xóa'},
  ];

  // Danh sách năm (từ năm hiện tại trở về trước 5 năm)
  List<int> get yearList {
    final currentYear = DateTime.now().year;
    return List.generate(6, (index) => currentYear - index);
  }

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
        // Lưu list gốc từ API
        allTimeOffList.assignAll(data);
        // Áp dụng filter local
        applyStatusFilter();
      },
    );
  }

  // Lọc local theo trạng thái và năm
  void applyStatusFilter() {
    List<TimeOff> filteredList = allTimeOffList.toList();

    // Lọc theo năm
    filteredList = filteredList.where((item) {
      if (item.fromDate == null) return false;
      return item.fromDate!.year == selectedYear.value;
    }).toList();

    // Lọc theo trạng thái
    if (selectedStatusCode.value != 'ALL') {
      filteredList = filteredList.where((item) {
        return item.status == selectedStatusCode.value;
      }).toList();
    }

    timeOffList.assignAll(filteredList);
  }

  // Thay đổi filter năm
  void onYearFilterChanged(int? year) {
    if (year == null) return;
    selectedYear.value = year;
    applyStatusFilter();
  }

  // Thay đổi filter trạng thái
  void onStatusFilterChanged(String? statusCode) {
    if (statusCode == null) return;

    // Tìm name từ code
    final filter = statusFilterList.firstWhere(
      (item) => item['code'] == statusCode,
      orElse: () => statusFilterList[0],
    );

    selectedStatusCode.value = statusCode;
    selectedStatusFilter.value = filter['name'] ?? 'Tất cả';
    applyStatusFilter();
  }

  Future<void> onRefresh() async {
    await loadTimeOffList();
    // Sau khi refresh, filter vẫn được giữ và áp dụng lại
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
      lsDetail:
          timeOff.details
              ?.map(
                (detail) => WorkCodeDetail(
                  jobCode: detail.jobCode,
                  soLuong: detail.soLuong,
                ),
              )
              .toList() ??
          [],
    );

    await handleApiCall<void>(
      apiCall: () => updateTimeOffUsecase.call(request),
      onSuccess: (id) {
        loadTimeOffList();
        // Filter sẽ được áp dụng lại trong loadTimeOffList
      },
    );
  }
}
