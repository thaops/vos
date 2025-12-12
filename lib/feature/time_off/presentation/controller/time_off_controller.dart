import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_list_usecase.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off/presentation/widgets/time_off_confirm_dialog.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/updateafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/createafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/updateafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/recall_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/models/time_off_update_args.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/send_approve_result.dart';
import 'package:vos_flutter/router/app_router.dart';

class TimeOffController extends BaseController with ApiResultMixin {
  final GetTimeOffListUsecase getTimeOffListUsecase;
  final GetTimeOffDetailUsecase getTimeOffDetailUsecase;
  final UpdateTimeOffUsecase updateTimeOffUsecase;
  final SendApproveRequestUsecase sendApproveRequestUsecase;
  final RecallTimeOffUsecase recallTimeOffUsecase;
  final CreateAflVosUsecase createAflVosUsecase;
  final UpdateAflVosUsecase updateAflVosUsecase;

  final RxList<TimeOff> timeOffList = <TimeOff>[].obs;
  final RxList<TimeOff> allTimeOffList = <TimeOff>[].obs;
  final RxString selectedStatusFilter = 'Tất cả'.obs;
  final RxString selectedStatusCode = 'ALL'.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString selectedYearId = DateTime.now().year.toString().obs;

  static const List<Map<String, String>> statusFilterList = [
    {'code': 'ALL', 'name': 'Tất cả'},
    {'code': '-', 'name': 'Chưa chuyển phê duyệt'},
    {'code': 'IN', 'name': 'Trong quá trình phê duyệt'},
    {'code': 'RJ', 'name': 'Từ chối'},
    {'code': 'FN', 'name': 'Đồng ý hoàn toàn'},
    {'code': 'HF', 'name': 'Đồng ý 1 phần'},
    {'code': 'BK', 'name': 'Thu hồi'},
  ];

  List<int> get yearList {
    final currentYear = DateTime.now().year;
    return List.generate(6, (index) => currentYear - index);
  }

  RxList<String> get yearOptions {
    return yearList.map((year) => year.toString()).toList().obs;
  }

  RxList<String> get statusOptions {
    return statusFilterList.map((filter) => filter['name']!).toList().obs;
  }

  TimeOffController({
    required this.getTimeOffListUsecase,
    required this.getTimeOffDetailUsecase,
    required this.updateTimeOffUsecase,
    required this.sendApproveRequestUsecase,
    required this.recallTimeOffUsecase,
    required this.createAflVosUsecase,
    required this.updateAflVosUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    selectedYearId.value = selectedYear.value.toString();
    loadTimeOffList();
  }

  Future<void> loadTimeOffList() async {
    await handleApiCall<List<TimeOff>>(
      apiCall: () => getTimeOffListUsecase.call(vRegId: 0, year: 0),
      onSuccess: (data) {
        allTimeOffList.assignAll(data);
        applyStatusFilter();
      },
    );
  }

  void applyStatusFilter() {
    List<TimeOff> filteredList = allTimeOffList.toList();

    filteredList = filteredList.where((item) {
      if (item.fromDate == null) return false;
      return item.fromDate!.year == selectedYear.value;
    }).toList();

    if (selectedStatusCode.value != 'ALL') {
      filteredList = filteredList.where((item) {
        return item.approveStatus == selectedStatusCode.value;
      }).toList();
    }

    timeOffList.assignAll(filteredList);
  }

  void onYearFilterChanged(String? yearId) {
    if (yearId == null || yearId.isEmpty) return;
    final year = int.tryParse(yearId);
    if (year == null) return;
    selectedYear.value = year;
    selectedYearId.value = yearId;
    applyStatusFilter();
  }

  void onStatusFilterChanged(String? statusCode) {
    if (statusCode == null) return;

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
  }

  Future<void> cancelTimeOff(TimeOff timeOff) async {
    final confirmed = await TimeOffConfirmDialog.show(
      type: TimeOffDialogType.cancel,
      title: 'Hủy đơn',
      message: 'Bạn có chắc muốn hủy đơn xin nghỉ phép này?',
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
      },
    );
  }

  Future<void> recallTimeOff(TimeOff timeOff) async {
    final confirmed = await TimeOffConfirmDialog.show(
      type: TimeOffDialogType.recall,
      title: 'Thu hồi',
      message: 'Bạn có chắc muốn thu hồi đơn xin nghỉ phép này?',
    );

    if (confirmed == true) {
      await _callUpdateAflVos(timeOff);
    }
  }

  // void _recallTimeOff(TimeOff timeOff) async {
  //   await handleApiCall<void>(
  //     apiCall: () => recallTimeOffUsecase.call(timeOff.vRegId),
  //     onSuccess: (_) async {
  //       await _callUpdateAflVos(timeOff);
  //       loadTimeOffList();
  //     },
  //   );
  // }

  Future<void> _callUpdateAflVos(TimeOff timeOff) async {
    try {
      String? email;
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        email = profileController.userProfile.value?.email;
      }

      final emailWithDefault = email ?? 'phongdh@viags.vn';

      final detailResult = await getTimeOffDetailUsecase.call(
        vRegId: timeOff.vRegId,
      );
      if (!detailResult.isSuccess || detailResult.data == null) {
        return;
      }

      final TimeOff timeOffDetail = detailResult.data!;
      final processes = timeOffDetail.processes ?? [];
      if (processes.isEmpty) {
        return;
      }

      final firstProcess = processes.first;
      final vAppId = firstProcess.approveNo; 

      final request = UpdateAflVosRequest.fromTimeOff(
        timeOff: timeOffDetail,
        processes: processes,
        vAppIdOverride: vAppId,
      );
      await handleApiCallVoid(
        apiCall: () => updateAflVosUsecase.call(
          request: request,
          vRegId: timeOff.vRegId,
          email: emailWithDefault,
        ),
        onSuccess: () {
          print('[UpdateAflVos] Gửi thành công');
          loadTimeOffList();
        },
        onError: (error) {
          print('[UpdateAflVos] Lỗi: $error');
        },
      );
    } catch (e) {
    }
  }

  Future<void> sendApproveRequest(TimeOff timeOff) async {
    final confirmed = await TimeOffConfirmDialog.show(
      type: TimeOffDialogType.sendApprove,
      title: 'Gửi phê duyệt',
      message: 'Bạn có chắc muốn gửi đơn xin nghỉ phép này để phê duyệt?',
    );

    if (confirmed == true) {
      await handleApiCall<SendApproveResult>(
        apiCall: () => sendApproveRequestUsecase.call(timeOff.vRegId),
        onSuccess: (result) async {
          await _callCreateAflVos(timeOff, result.approvals);

          SuccessDialog.show(
            context: Get.context!,
            title: 'Thành công',
            message: 'Gửi phê duyệt thành công',
            buttonText: 'Đóng',
            onClose: () {
              loadTimeOffList();
            },
          );
        },
      );
    }
  }

  Future<void> _callCreateAflVos(
    TimeOff timeOff,
    List<ApprovalItem> approvalsFromApi,
  ) async {
    try {
      String? email;
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        email = profileController.userProfile.value?.email;
      }

      final emailWithDefault = email ?? 'phongdh@viags.vn';

      final processes = timeOff.processes ?? [];
      if (processes.isEmpty) {
        print('[CreateAflVos] Không có processes, bỏ qua');
        return;
      }

      final request = CreateAflVosRequest.fromTimeOff(
        timeOff: timeOff,
        processes: processes,
        approvalsOverride: approvalsFromApi,
      );

      await handleApiCallVoid(
        apiCall: () =>
            createAflVosUsecase.call(request: request, email: emailWithDefault),
        onSuccess: () {
          print('[CreateAflVos] Gửi thành công');
        },
        onError: (error) {
          print('[CreateAflVos] Lỗi: $error');
        },
      );
    } catch (e) {
      print('[CreateAflVos] Exception: $e');
    }
  }

  void navigateToUpdate(TimeOff timeOff) {
    Get.toNamed(
      AppRouter.timeOffUpdate,
      arguments: TimeOffUpdateArgs(timeOff: timeOff),
    )?.then((result) {
      if (result == true) {
        loadTimeOffList();
      }
    });
  }

  bool isDraft(TimeOff timeOff) {
    final approveStatus = timeOff.approveStatus ?? '-';
    final approveProcessName = timeOff.appoveProcessName ?? '';
    final result =
        approveStatus == '--' ||
        approveStatus == '-' ||
        approveProcessName.toLowerCase().contains(
          'chưa chuyển cho cán bộ phê duyệt',
        );

    return result;
  }

  bool canCancel(TimeOff timeOff) {
    final approveStatus = timeOff.approveStatus ?? '-';
    final statusName = timeOff.statusName ?? '';
    return approveStatus == 'IN' ||
        approveStatus == 'FN' ||
        approveStatus == 'HF' ||
        statusName.toLowerCase().contains('chờ phê duyệt') ||
        statusName.toLowerCase().contains('đã phê duyệt');
  }
}
