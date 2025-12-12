import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/models/time_off_update_args.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/send_approve_result.dart';
import 'package:vos_flutter/router/app_router.dart';

class TimeOffDetailController extends BaseController with ApiResultMixin {
  final TimeOffDetailArgs args;
  final GetTimeOffDetailUsecase getTimeOffDetailUsecase;
  final SendApproveRequestUsecase sendApproveRequestUsecase;
  final UpdateTimeOffUsecase updateTimeOffUsecase;

  late final int vRegId = args.vRegId;

  final Rx<TimeOff?> timeOffDetail = Rx<TimeOff?>(null);

  TimeOffDetailController({
    required this.args,
    required this.getTimeOffDetailUsecase,
    required this.sendApproveRequestUsecase,
    required this.updateTimeOffUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    loadTimeOffDetail();
  }

  Future<void> loadTimeOffDetail() async {
    await handleApiCall<TimeOff>(
      apiCall: () => getTimeOffDetailUsecase.call(vRegId: vRegId),
      onSuccess: (data) {
        timeOffDetail.value = data;
      },
    );
  }

  Future<void> onRefresh() async {
    await loadTimeOffDetail();
  }

  // Kiểm tra đơn có phải "Soạn thảo" không
  bool get isDraft {
    final timeOff = timeOffDetail.value;
    if (timeOff == null) return false;
    final approveStatus = timeOff.approveStatus ?? '-';
    final statusName = timeOff.statusName ?? '';
    // Soạn thảo: approveStatus == '-' hoặc statusName chứa "Soạn thảo"
    return approveStatus == '-' ||
        statusName.toLowerCase().contains('soạn thảo');
  }

  // Kiểm tra đơn có thể hủy không (Chờ phê duyệt, Đã phê duyệt)
  bool get canCancel {
    final timeOff = timeOffDetail.value;
    if (timeOff == null) return false;
    final approveStatus = timeOff.approveStatus ?? '-';
    final statusName = timeOff.statusName ?? '';
    // Chờ phê duyệt: approveStatus == 'IN'
    // Đã phê duyệt: approveStatus == 'FN' hoặc 'HF'
    return approveStatus == 'IN' ||
        approveStatus == 'FN' ||
        approveStatus == 'HF' ||
        statusName.toLowerCase().contains('chờ phê duyệt') ||
        statusName.toLowerCase().contains('đã phê duyệt');
  }

  // Gửi phê duyệt
  Future<void> sendApproveRequest() async {
    await handleApiCall<SendApproveResult>(
      apiCall: () => sendApproveRequestUsecase.call(vRegId),
      onSuccess: (_) {
        SuccessDialog.show(
          context: Get.context!,
          title: 'Thành công',
          message: 'Gửi phê duyệt thành công',
          buttonText: 'Đóng',
          onClose: () {
            loadTimeOffDetail();
          },
        );
      },
    );
  }

  // Chỉnh sửa - chuyển sang màn hình update
  void navigateToUpdate() {
    final timeOff = timeOffDetail.value;
    if (timeOff != null) {
      Get.toNamed(
        AppRouter.timeOffUpdate,
        arguments: TimeOffUpdateArgs(timeOff: timeOff),
      )?.then((result) {
        if (result == true) {
          loadTimeOffDetail();
        }
      });
    }
  }


    String buildStatusTag(String status) {
    switch (status) {
      case '--':
        return 'Chưa chuyển cho cán bộ phê duyệt';
      case 'IN':
        return 'Đang trong quá trình phê duyệt';
      case 'FN':
        return 'Được phê duyệt';
      case 'RJ':
        return 'Từ chối';
      case 'BK':
        return 'Thu hồi';
      case 'OK':
        return 'Chưa phê duyệt';
      default:
        return '--';
    }
  }

  Color buildStatusColor(String status) {
    switch (status) {
      case '--':
        return Colors.grey;
      case 'IN':
        return Colors.orange;
      case 'FN':
        return Colors.green;
      case 'RJ':
        return Colors.red;
      case 'BK':
        return Colors.blueGrey;
      case 'OK':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Thu hồi đơn
  Future<void> recallTimeOff() async {
    final timeOff = timeOffDetail.value;
    if (timeOff == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Thu hồi đơn'),
        content: const Text('Bạn có chắc muốn thu hồi đơn xin nghỉ phép này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final request = TimeOffCreateRequest(
        vRegId: timeOff.vRegId,
        fromDate: timeOff.fromDate ?? DateTime.now(),
        domInt: timeOff.domInt ?? '',
        description: timeOff.description ?? '',
        vacationReason: timeOff.vacationReason ?? '',
        contactPerson: timeOff.contactPerson ?? '',
        contactInfor: timeOff.contactInfor ?? '',
        status: timeOff.status ?? '',
        recUserID: timeOff.hrId ?? 0,
        lsDetail: timeOff.details
                ?.map(
                  (detail) => WorkCodeDetail(
                    jobCode: detail.jobCode,
                    soLuong: detail.soLuong,
                  ),
                )
                .toList() ??
            [],
        approveStatus: 'BK',
      );

      await handleApiCall<int>(
        apiCall: () => updateTimeOffUsecase.call(request),
        onSuccess: (id) {
          SuccessDialog.show(
            context: Get.context!,
            title: 'Thành công',
            message: 'Thu hồi đơn thành công',
            buttonText: 'Đóng',
            onClose: () {
              loadTimeOffDetail();
            },
          );
        },
      );
    }
  }

  // Hủy đơn
  Future<void> cancelTimeOff() async {
    final timeOff = timeOffDetail.value;
    if (timeOff == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hủy đơn'),
        content: const Text('Bạn có chắc muốn hủy đơn xin nghỉ phép này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
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
        lsDetail: timeOff.details
                ?.map(
                  (detail) => WorkCodeDetail(
                    jobCode: detail.jobCode,
                    soLuong: detail.soLuong,
                  ),
                )
                .toList() ??
            [],
      );

      await handleApiCall<int>(
        apiCall: () => updateTimeOffUsecase.call(request),
        onSuccess: (id) {
          SuccessDialog.show(
            context: Get.context!,
            title: 'Thành công',
            message: 'Hủy đơn thành công',
            buttonText: 'Đóng',
            onClose: () {
              loadTimeOffDetail();
            },
          );
        },
      );
    }
  }
}

