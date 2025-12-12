import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/utils/date_utils.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/router/app_router.dart';

class TimeOffCard extends StatelessWidget {
  final TimeOff timeOff;
  final VoidCallback? onCancel;
  final VoidCallback? onRecall;
  final VoidCallback? onSendApprove;
  final VoidCallback? onEdit;

  const TimeOffCard({
    super.key,
    required this.timeOff,
    this.onCancel,
    this.onRecall,
    this.onSendApprove,
    this.onEdit,
  });

  // Map approveStatus với text và màu sắc
  static const Map<String, Map<String, dynamic>> approveStatusMap = {
    '-': {
      'text': 'Chưa chuyển phê duyệt',
      'bgColor': Color(0xFFF5F5F5),
      'textColor': Color(0xFF666666),
    },
    'IN': {
      'text': 'Trong quá trình phê duyệt',
      'bgColor': Color(0xFFFFF3E0),
      'textColor': Color(0xFFF57C00),
    },
    'RJ': {
      'text': 'Từ chối',
      'bgColor': Color(0xFFFFEBEE),
      'textColor': Color(0xFFD32F2F),
    },
    'FN': {
      'text': 'Đồng ý hoàn toàn',
      'bgColor': Color(0xFFE0FFF3),
      'textColor': Color(0xFF00B894),
    },
    'HF': {
      'text': 'Đồng ý 1 phần',
      'bgColor': Color(0xFFE3F2FD),
      'textColor': Color(0xFF1976D2),
    },
    'BK': {
      'text': 'Thu hồi',
      'bgColor': Color(0xFFFFF3E0),
      'textColor': Color(0xFFE65100),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRouter.timeOffDetail,
            arguments: TimeOffDetailArgs(vRegId: timeOff.vRegId),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Thời gian nghỉ + Status chip
              _buildHeader(),
              SizedBox(height: 20.h),

              // Body: Thông tin chi tiết
              _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'Ngày đăng ký',
                value: _formatDateTime(timeOff.dateReg),
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.description,
                label: 'Phê duyệt',
                value: timeOff.approvalProgressText,
              ),
              SizedBox(height: 8.h),
              Divider(color: AppColors.grey, thickness: 1),
              SizedBox(height: 8.h),
              _buildInfoItem(
                icon: Icons.note,
                label: 'Mô tả chi tiết',
                value: timeOff.description ?? 'Không có',
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.label_outline,
                label: 'Loại',
                value: _formatVacationType(),
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.location_on,
                label: 'Nơi nghỉ',
                value: timeOff.domIntName ?? 'Không có',
              ),

              // Footer: Action buttons
              SizedBox(height: 16.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Date range
        Expanded(
          flex: 2,
          child: Text(
            _formatDateRange(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12.w),
        // Status chip
        Expanded(flex: 1, child: _buildStatusChip()),
      ],
    );
  }

  Widget _buildStatusChip() {
    final approveStatus = timeOff.approveStatus ?? '-';
    final statusInfo =
        approveStatusMap[approveStatus] ??
        approveStatusMap['-']!; // Fallback về '-' nếu không tìm thấy

    final statusText = statusInfo['text'] as String;
    final bgColor = statusInfo['bgColor'] as Color;
    final textColor = statusInfo['textColor'] as Color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
          overflow: TextOverflow.ellipsis,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final approveStatus = timeOff.approveStatus ?? '-';
    final approveProcessName = timeOff.appoveProcessName ?? '';
    final statusCode = timeOff.status ?? '';

    // Kiểm tra đơn "Soạn thảo"
    final isDraft =
        approveStatus == '--' ||
        approveProcessName.toLowerCase().contains(
          'Chưa chuyển cho cán bộ phê duyệt',
        );

    final canRecall =
        approveStatus == 'IN' || approveStatus == 'FN' || approveStatus == 'HF';
    final statusXX = statusCode == 'XX' || statusCode == 'RJ';
    final StatusBK = statusCode == 'BK';

    if (isDraft) {
      return Row(
        children: [
          if (onSendApprove != null && !statusXX) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: onSendApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Gửi phê duyệt',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (onSendApprove != null && onEdit != null) SizedBox(width: 8.w),
          // Chỉnh sửa
          if (onEdit != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade300, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Chỉnh sửa',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ),
          ],
          if (onEdit != null && onCancel != null) SizedBox(width: 8.w),
          // Hủy
          if (onCancel != null && !statusXX) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Đơn "Chờ phê duyệt", "Đã phê duyệt": Thu hồi
    if (canRecall && onRecall != null && !StatusBK) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onRecall,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red.shade300, width: 1.5),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Thu hồi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  String _formatDateRange() {
    final from = timeOff.fromDate != null
        ? DateUtilsCustom.formatDate(timeOff.fromDate)
        : 'N/A';
    final to = timeOff.toDate != null
        ? DateUtilsCustom.formatDate(timeOff.toDate)
        : 'N/A';
    return '$from – $to';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    // Format: dd/MM/yyyy HH:mm (ví dụ: 29/07/2025 15:23)
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatVacationType() {
    return timeOff.vacationReasonName ?? '';
  }
}
