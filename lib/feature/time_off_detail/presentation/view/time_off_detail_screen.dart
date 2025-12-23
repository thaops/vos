import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/utils/date_utils.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
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
        title: 'Thông tin nghỉ phép/ chế độ',
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
                          isWide: isWide,
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
    required bool isWide,
  }) {
    final creatorProcess =
        (timeOff.processes != null && timeOff.processes!.isNotEmpty)
        ? timeOff.processes!.first
        : null;
    final timeOffQuantityText = _formatTimeOffQuantity(timeOff);

    return Obx(() {
      // ✅ Safe check ProfileController trước khi sử dụng
      if (!Get.isRegistered<ProfileController>()) {
        return const SizedBox.shrink();
      }

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

      Widget wrapItem(Widget child, {double? width}) {
        return SizedBox(width: width ?? fieldWidth, child: child);
      }

      Widget buildSummaryRow(List<Widget> stats) {
        return Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              Expanded(child: stats[i]),
              if (i != stats.length - 1) SizedBox(width: 12.w),
            ],
          ],
        );
      }

      final items = [
        wrapItem(
          _buildInfoRow(
            label: "Người nghỉ",
            value: _formatPersonWithHrNo(hrNoStr, creatorProcess),
            size: 15,
          ),
        ),
        wrapItem(
          _buildInfoRow(label: "Email", value: creatorProcess?.email ?? ''),
        ),
        wrapItem(
          _buildInfoRow(
            label: 'Chức danh',
            value: creatorProcess?.nameJobTitle ?? '',
          ),
        ),
        wrapItem(
          _buildInfoRow(
            label: 'Cơ quan / Đơn vị',
            value: timeOff.level2Name ?? '',
          ),
        ),
        wrapItem(
          _buildInfoRow(
            label: 'Thời gian nghỉ',
            value:
                "${(timeOffQuantityText)} ngày (${_formatDateRange(timeOff)})",
          ),
        ),
        wrapItem(
          _buildInfoRow(
            label: 'Loại phép',
            value: timeOff.vacationReasonName ?? 'N/A',
          ),
        ),
        wrapItem(
          _buildInfoRow(label: 'Nơi nghỉ', value: timeOff.domIntName ?? 'N/A'),
        ),
        if (timeOff.description != null && timeOff.description!.isNotEmpty)
          wrapItem(
            _buildInfoRow(
              label: 'Mô tả chi tiết',
              value: timeOff.description ?? '',
              isMultiline: true,
            ),
          ),
      ];

      final paidLeaveRemain = personalVacation?.paidLeaveRemain;
      final paidLeaveUsedTotal =
          personalVacation?.paidLeaveUsedTotal.toDouble() ?? 0;
      final overTimeRemain = personalVacation?.overTimeRemain.toDouble() ?? 0;

      final summaryStats = <Widget>[];
      if (paidLeaveRemain != null) {
        summaryStats.add(
          _buildInfoRow2(
            label: 'Tồn phép',
            value: paidLeaveRemain.toStringAsFixed(0),
          ),
        );
      }
      summaryStats.add(
        _buildInfoRow2(
          label: 'Tồn OT',
          value: overTimeRemain.toStringAsFixed(0),
        ),
      );
      summaryStats.add(
        _buildInfoRow2(
          label: 'Phép đã sử dụng',
          value: paidLeaveUsedTotal.toStringAsFixed(0),
        ),
      );

      final allItems = List<Widget>.from(items);
      if (summaryStats.isNotEmpty) {
        final fullWidth = isWide ? (fieldWidth * 2 + 12.w) : fieldWidth;
        allItems.add(wrapItem(buildSummaryRow(summaryStats), width: fullWidth));
      }

      return Wrap(spacing: 12.w, runSpacing: 16.h, children: allItems);
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

          final groupedProcesses = grouped.values.toList();
          final totalSteps = max(
            totalStepsFromProcess ?? maxApproveNo,
            groupedProcesses.length,
          );
          final approvedCount = timeOff.processes!
              .where((p) => _isApprovedStatus(p.status))
              .length;
          final length = timeOff.processes!.length;

          return groupedProcesses.asMap().entries.map((entry) {
            final index = entry.key;
            final processes = entry.value;
            final isLast = index == groupedProcesses.length - 1;
            final lengthGroup = processes.length;

            return _buildTimelineStep(
              processes: processes,
              lengthGroup: lengthGroup,
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
    required int lengthGroup,
    required int totalSteps,
    required int approvedCount,
    required int length,
    required bool isLast,
    required int index,
  }) {
    final names = processes.isNotEmpty ? processes.first.title : '';
    // Hiển thị thứ tự bước thay vì số người trong nhóm
    final stepHeader = '${index + 1}/$totalSteps: $names';
    final groupStatus = _resolveGroupStatus(processes);
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Step header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  stepHeader,
                  maxLines: 2,
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
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: controller
                      .buildStatusColor(groupStatus, index)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.r),
                  border: Border.all(
                    color: controller.buildStatusColor(groupStatus, index),
                  ),
                ),
                child: Text(
                  baseStatusTag,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: controller.buildStatusColor(groupStatus, index),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...processes.map((process) {
            return Container(
              margin: EdgeInsets.only(
                top: process == processes.first ? 0 : 8.h,
              ),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: controller
                    .buildStatusColor(process.status, index)
                    .withOpacity(0.1),
                border: Border.all(
                  color: controller.buildStatusColor(process.status, index),
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar icon
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.black.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 22.sp,
                      color: AppColors.black.withOpacity(0.5),
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
                        SizedBox(height: 4.h),
                        Text(
                          process.nameJobTitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _colorTextGray,
                          ),
                        ),

                        if (process.recdate != null &&
                            (process.status.toLowerCase() == 'yes' ||
                                process.status.toLowerCase() == 'no')) ...[
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
                  process.dutyType == 'SUB'
                      ? Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.w),
                          ),
                          child: Text(
                            'Uỷ quyền',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
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

  final statuses = processes
      .map((p) => (p.status).toLowerCase().trim())
      .toList();

  final bool allDash = statuses.every((s) => s == '--');
  final bool hasNo = statuses.contains('no');
  final bool hasYes = statuses.contains('yes');

  if (allDash) {
    return '--';
  }

  if (hasNo) {
    return 'no';
  }

  if (hasYes) {
    return 'yes';
  }

  return '--';
}

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
        SizedBox(
          width: 110.w,
          child: TextWidget(
            text: '$label:',
            fontSize: 12,
            color: TimeOffCreateColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: TextWidget(
            text: value,
            fontSize: 12,
            color: TimeOffCreateColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow2({required String label, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 110.w),
            child: TextWidget(
              text: '$label:',
              fontSize: 12,
              color: TimeOffCreateColors.textSecondary,
              fontWeight: FontWeight.w400,
              maxLines: 1,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: TextWidget(
            text: value,
            fontSize: 12,
            color: TimeOffCreateColors.textPrimary,
            fontWeight: FontWeight.w600,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  String _formatDateRange(TimeOff timeOff) {
    final fromDate = timeOff.fromDate;
    final toDate = timeOff.toDate;

    if (fromDate == null && toDate == null) return 'N/A – N/A';
    if (fromDate == null) return 'N/A – ${DateUtilsCustom.formatDate(toDate)}';
    if (toDate == null) return '${DateUtilsCustom.formatDate(fromDate)} – N/A';

    if (fromDate.year == toDate.year) {
      final fromShort = DateFormat('dd/MM').format(fromDate);
      final toFull = DateFormat('dd/MM/yyyy').format(toDate);
      return '$fromShort - $toFull';
    }

    final from = DateUtilsCustom.formatDate(fromDate);
    final to = DateUtilsCustom.formatDate(toDate);
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
    return status.toLowerCase() == 'yes';
  }
}
