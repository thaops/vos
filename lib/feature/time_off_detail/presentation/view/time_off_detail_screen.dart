import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/img/img.dart';
import 'package:vos_flutter/common/utils/date_utils.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/controller/time_off_detail_controller.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/widgets/file_attachments_section.dart';

class TimeOffDetailScreen extends GetView<TimeOffDetailController> {
  const TimeOffDetailScreen({super.key});

  static const _colorTextDark = Color(0xFF212121);
  static const _colorTextGray = Color(0xFF666666);
  static const _colorBackground = Color(0xFFF5F5F5);
  static const _colorStatusApproved = Color(0xFF4CAF50); 
  static const _colorStatusProcessing = Color(0xFFFF9800); 
  static const _colorStatusRejected = Color(0xFFE53935); 

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
                        SizedBox(height: 20.h),
                        _buildCommentSection(timeOff),
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

  // Section 1: Thông tin chung (Form Detail Section)
  Widget _buildGeneralInfoSection(
    TimeOff timeOff, {
    required double fieldWidth,
  }) {
    final creatorProcess =
        (timeOff.processes != null && timeOff.processes!.isNotEmpty)
        ? timeOff.processes!.first
        : null;

    final items = [
      _buildInfoRow(
        label: 'Người tạo đơn',
        value: _formatPersonWithHrId(timeOff, creatorProcess),
      ),
      _buildInfoRow(
        label: "Người nghỉ",
        value: _formatPersonWithHrId(timeOff, creatorProcess),
      ),
      _buildInfoRow(label: "Email", value: creatorProcess?.email ?? ''),
      _buildInfoRow(label: 'Chức danh', value: timeOff.nameLevelTitle ?? ''),
      _buildInfoRow(label: 'Cơ quan / Đơn vị', value: timeOff.level2Name ?? ''),
      _buildInfoRow(label: 'Đơn vị', value: timeOff.level3Name ?? ''),
      _buildInfoRow(label: 'Đội / Tổ:', value: timeOff.level3Name ?? ''),
      _buildInfoRow(label: 'Từ ngày', value: _formatDateRange(timeOff)),
      _buildInfoRow(
        label: 'Thời gian nghỉ',
        value: timeOff.vacationNo?.toString() ?? '',
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
      if (timeOff.phepTon != null)
        _buildInfoRow(
          label: 'Tiêu chuẩn phép',
          value: timeOff.phepTon!.toStringAsFixed(0),
        ),
      _buildInfoRow(
        label: 'Tổng ngày phép nghỉ',
        value: timeOff.vacationNo?.toString() ?? '',
      ),
      if (timeOff.overtimeTon != null)
        _buildInfoRow(
          label: 'Tồn OT',
          value: timeOff.overtimeTon!.toStringAsFixed(0),
        ),
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 16.h,
      children: items
          .map((item) => SizedBox(width: fieldWidth, child: item))
          .toList(),
    );
  }

  // Section 2: Quy trình phê duyệt (Timeline)
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
        ...timeOff.processes!.asMap().entries.map((entry) {
          final index = entry.key;
          final process = entry.value;
          final isLast = index == timeOff.processes!.length - 1;
          final totalSteps = timeOff.processes!.length;
          final approvedCount = timeOff.processes!
              .where((p) => p.status == 'OK')
              .length;

          return _buildTimelineStep(
            process: process,
            stepNumber: index + 1,
            totalSteps: totalSteps,
            approvedCount: approvedCount,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineStep({
    required TimeOffProcess process,
    required int stepNumber,
    required int totalSteps,
    required int approvedCount,
    required bool isLast,
  }) {
    final isApproved = process.status == 'OK';
    final isRejected = process.status == 'XX';

    // Header step: "3/5: Thủ trưởng CQ/ĐV"
    final stepHeader = '$stepNumber/$totalSteps: ${process.fullName}';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepHeader,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: _colorTextDark,
                ),
              ),
              SizedBox(width: 8.w),
              // Status tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isApproved
                      ? _colorStatusApproved.withOpacity(0.1)
                      : isRejected
                      ? _colorStatusRejected.withOpacity(0.1)
                      : _colorStatusProcessing.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.r),
                  border: Border.all(
                    color: isApproved
                        ? _colorStatusApproved
                        : isRejected
                        ? _colorStatusRejected
                        : _colorStatusProcessing,
                  ),
                ),
                child: Text(
                  isApproved
                      ? 'Đã duyệt'
                      : isRejected
                      ? 'Từ chối'
                      : 'Đang xử lý',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isApproved
                        ? _colorStatusApproved
                        : isRejected
                        ? _colorStatusRejected
                        : _colorStatusProcessing,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Card người phê duyệt
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _colorBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                // Avatar
                Image.asset(Img.avatarTimeOff),
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
                      if (process.recdate != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _formatDateTime(process.recdate),
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
          ),
        ],
      ),
    );
  }

  // Section 3: Thông tin trao đổi (Comment Section)
  Widget _buildCommentSection(TimeOff timeOff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin trao đổi',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        // Placeholder: Chưa có comment
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Chưa có thông tin trao đổi',
                  style: TextStyle(fontSize: 14.sp, color: _colorTextGray),
                ),
              ],
            ),
          ),
        ),
        // Input comment (có thể implement sau khi có API)
        // SizedBox(height: 16.h),
        // _buildCommentInput(),
      ],
    );
  }

  // Helper: Info Row (Label-Value Layout)
  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: _colorTextGray,
            ),
          ),
        ),
        SizedBox(width: 8.h),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
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
    return DateUtilsCustom.formatStringDate(
      date.toIso8601String(),
      isHour: true,
    );
  }

  String _formatPersonWithHrId(TimeOff timeOff, TimeOffProcess? process) {
    final hrIdStr = timeOff.hrId != null && timeOff.hrId! > 0
        ? '${timeOff.hrId}'
        : '';
    final name = process?.fullName ?? '';

    if (hrIdStr.isNotEmpty && name.isNotEmpty) {
      return '$hrIdStr - $name';
    }
    return hrIdStr.isNotEmpty ? hrIdStr : name;
  }
}
