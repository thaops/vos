import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/utils/date_utils.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/controller/time_off_detail_controller.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/widgets/file_attachments_section.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class TimeOffDetailScreen extends GetView<TimeOffDetailController> {
  const TimeOffDetailScreen({super.key});

  static const _colorTextDark = Color(0xFF212121);
  static const _colorTextGray = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: 'Xem xét yêu cầu duyệt',
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (controller.status == ControllerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final timeOff = controller.timeOffDetail.value;
        if (timeOff == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth = constraints.maxWidth > 1100
                ? 1100.0
                : constraints.maxWidth;
            final isWide = maxContentWidth >= 820;
            final fieldWidth = isWide
                ? (maxContentWidth - 16) / 2
                : maxContentWidth;

            return RefreshIndicator(
              onRefresh: controller.onRefresh,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGeneralInfoSection(
                          timeOff,
                          fieldWidth: fieldWidth,
                        ),
                        SizedBox(height: 20.h),
                        if (timeOff.attachFiles != null &&
                            timeOff.attachFiles!.isNotEmpty)
                          FileAttachmentsSection(
                            attachments: timeOff.attachFiles!,
                          ),
                        SizedBox(height: 20.h),
                        _buildApprovalProcessSection(timeOff),
                        // SizedBox(height: 20.h),
                        // _buildCommentSection(timeOff),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildGeneralInfoSection(
    TimeOff timeOff, {
    required double fieldWidth,
  }) {
    final creatorProcess =
        (timeOff.processes != null && timeOff.processes!.isNotEmpty)
        ? timeOff.processes!.first
        : null;
    final timeOffQuantityText = _formatTimeOffQuantity(timeOff);

    return Obx(() {
      final profileController = Get.find<ProfileController>();
      final personalVacation = profileController.personalVacation.value;
      final userProfile = profileController.userProfile.value;

      if (personalVacation == null && userProfile != null) {
        profileController.loadPersonalVacation();
      }

      final hrNoStr = personalVacation?.hrNo.isNotEmpty == true
          ? personalVacation!.hrNo
          : (userProfile?.hrNo.isNotEmpty == true
                ? userProfile!.hrNo
                : (userProfile?.hrId != null && userProfile!.hrId > 0
                      ? '${userProfile.hrId}'
                      : ''));

      final items = [
        // _buildInfoRow(
        //   label: 'Người tạo đơn',
        //   value: _formatPersonWithHrNo(hrNoStr, creatorProcess),
        // ),
        _buildInfoRow(
          label: "Người nghỉ",
          value: _formatPersonWithHrNo(hrNoStr, creatorProcess),
          size: 15,
        ),
        _buildInfoRow(label: "Email", value: creatorProcess?.email ?? ''),
        _buildInfoRow(label: 'Chức danh', value: timeOff.nameLevelTitle ?? ''),
        _buildInfoRow(
          label: 'Cơ quan / Đơn vị',
          value: timeOff.level2Name ?? '',
        ),
      ];

      final paidLeaveYear = personalVacation?.paidLeaveYear;

      final paidLeaveUsedTotal = personalVacation != null
          ? personalVacation.paidLeaveUsedTotal.toDouble()
          : null;
      final overTimeRemain = personalVacation != null
          ? personalVacation.overTimeRemain.toDouble()
          : null;

      final allItems = List<Widget>.from(items);
      if (paidLeaveYear != null) {
        allItems.add(
          _buildInfoRow(
            label: 'Tiêu chuẩn phép',
            value: paidLeaveYear.toStringAsFixed(0),
          ),
        );
      }
      if (paidLeaveUsedTotal != null) {
        allItems.add(
          _buildInfoRow(
            label: 'Tổng phép nghỉ',
            value: paidLeaveUsedTotal.toStringAsFixed(0),
          ),
        );
      }
      if (overTimeRemain != null) {
        allItems.add(
          _buildInfoRow(
            label: 'Tồn OT',
            value: overTimeRemain.toStringAsFixed(0),
          ),
        );
      }

      allItems.addAll([
        _buildInfoRow(
          label: 'Thời gian nghỉ',
          value: "${(timeOffQuantityText)} (${_formatDateRange(timeOff)})",
        ),
        _buildInfoRow(
          label: 'Loại phép',
          value: timeOff.vacationReasonName ?? 'N/A',
        ),
        _buildInfoRow(label: 'Nơi nghỉ', value: timeOff.domIntName ?? 'N/A'),
        _buildInfoRow(
          label: 'Mô tả chi tiết',
          value: timeOff.description ?? '',
          isMultiline: true,
        ),
      ]);

      return Wrap(
        spacing: 12.w,
        runSpacing: 16.h,
        children: allItems
            .map((item) => SizedBox(width: fieldWidth, child: item))
            .toList(),
      );
    });
  }

  String _formatTimeOffQuantity(TimeOff timeOff) {
    final total = timeOff.totalTimeOff;
    if (total == 0) return '0';
    final text = total.toStringAsFixed(2);
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  Widget _buildApprovalProcessSection(TimeOff timeOff) {
    if (timeOff.processes == null || timeOff.processes!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quy trình phê duyệt',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        ...(() {
          final grouped = <int, List<TimeOffProcess>>{};
          var maxApproveNo = 0;
          for (final process in timeOff.processes!) {
            grouped.putIfAbsent(process.approveNo, () => []).add(process);
            if (process.approveNo > maxApproveNo) {
              maxApproveNo = process.approveNo;
            }
          }

          int? totalStepsFromProcess;
          final rawProcess = timeOff.appoveProcess;
          if (rawProcess != null && rawProcess.trim().isNotEmpty) {
            final match = RegExp(r'\d+').firstMatch(rawProcess);
            if (match != null) {
              totalStepsFromProcess = int.tryParse(match.group(0)!);
            }
          }

          final totalStepsForDisplay = totalStepsFromProcess ?? maxApproveNo;

          final groupedProcesses = grouped.values.toList();
          final approvedCount = timeOff.processes!
              .where((p) => _isApprovedStatus(p.status))
              .length;
          final length = timeOff.processes!.length;

          return groupedProcesses.asMap().entries.map((entry) {
            final index = entry.key;
            final processes = entry.value;
            final isLast = index == groupedProcesses.length - 1;
            final totalSteps = totalStepsForDisplay;

            return _buildTimelineStep(
              processes: processes,
              stepNumber: index + 1,
              totalSteps: totalSteps,
              approvedCount: approvedCount,
              length: length,
              isLast: isLast,
              index: index,
            );
          }).toList();
        }()),
      ],
    );
  }

  Widget _buildTimelineStep({
    required List<TimeOffProcess> processes,
    required int stepNumber,
    required int totalSteps,
    required int approvedCount,
    required int length,
    required bool isLast,
    required int index,
  }) {
    // Header step: "3/5: Thủ trưởng CQ/ĐV"
    final names = processes.map((p) => p.fullName).join(', ');
    final stepHeader = '$stepNumber/$length';
    final groupStatus = _resolveGroupStatus(processes);
    final totalMembers = processes.length;
    final approvedInGroup = processes
        .where((p) => _isApprovedStatus(p.status))
        .length;
    final groupProgressText = '$approvedInGroup/$totalMembers';
    final baseStatusTag = controller.buildStatusTag(groupStatus, index);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          Row(
            children: [
              Expanded(
                child: Text(
                  stepHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: _colorTextDark,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Status tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: controller
                      .buildStatusColor(groupStatus)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.r),
                  border: Border.all(
                    color: controller.buildStatusColor(groupStatus),
                  ),
                ),
                child: Text(
                  baseStatusTag,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: controller.buildStatusColor(groupStatus),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Card người phê duyệt
          ...processes.map((process) {
            return Container(
              margin: EdgeInsets.only(
                top: process == processes.first ? 0 : 8.h,
              ),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: controller
                    .buildStatusColor(process.status)
                    .withOpacity(0.1),
                border: Border.all(
                  color: controller.buildStatusColor(process.status),
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // Avatar icon
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 22.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          process.fullName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: _colorTextDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          process.email,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _colorTextGray,
                          ),
                        ),
                        if (process.recdate != null &&
                            process.status != '--' &&
                            process.status != 'OK') ...[
                          SizedBox(height: 4.h),
                          Text(
                            "Ngày duyệt: ${_formatDateTime(process.recdate)}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _colorTextGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _resolveGroupStatus(List<TimeOffProcess> processes) {
    if (processes.isEmpty) return '--';

    // Chuẩn hóa status về uppercase để so sánh an toàn
    final statuses = processes.map((p) => (p.status).toUpperCase()).toList();

    final bool allDash = statuses.every((s) => s == '--');
    final bool allFn = statuses.every((s) => s == 'FN');
    final bool allOk = statuses.every((s) => s == 'OK');
    final bool hasRj = statuses.contains('RJ');

    // 1) Tất cả là '--' → chưa gửi phê duyệt
    if (allDash) {
      return '--';
    }

    // 2) Có ít nhất 1 'RJ' → cả group bị từ chối
    if (hasRj) {
      return 'RJ';
    }

    // 3) Tất cả là 'FN' → cả group đã duyệt
    if (allFn) {
      return 'FN';
    }

    // 4) Tất cả là 'OK' → chưa phê duyệt
    if (allOk) {
      return 'OK';
    }

    // 5) Các trường hợp còn lại → đang trong quá trình phê duyệt
    return 'IN';
  }

  // Helper: Info Row (Label-Value Layout)
  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isMultiline = false,
    int? size = 13,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: _colorTextGray,
            ),
          ),
        ),
        SizedBox(width: 4.h),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              fontSize: size?.sp,
              fontWeight: FontWeight.w500,
              color: _colorTextDark,
            ),
            maxLines: isMultiline ? null : 2,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper: Format Date Range
  String _formatDateRange(TimeOff timeOff) {
    final from = timeOff.fromDate != null
        ? DateUtilsCustom.formatDate(timeOff.fromDate)
        : 'N/A';
    final to = timeOff.toDate != null
        ? DateUtilsCustom.formatDate(timeOff.toDate)
        : 'N/A';
    return '$from – $to';
  }

  // Helper: Format DateTime
  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatPersonWithHrNo(String hrNoStr, TimeOffProcess? process) {
    final name = process?.fullName ?? '';

    if (hrNoStr.isNotEmpty && name.isNotEmpty) {
      return '$hrNoStr - $name';
    }
    return hrNoStr.isNotEmpty ? hrNoStr : name;
  }

  bool _isApprovedStatus(String status) {
    return status == 'OK' || status == 'FN';
  }
}
