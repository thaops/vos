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
  final Map<String, String>? statusNameByCode;
  final bool isRecallLoading;
  final bool isCancelLoading;
  final bool isSendApproveLoading;

  const TimeOffCard({
    super.key,
    required this.timeOff,
    this.onCancel,
    this.onRecall,
    this.onSendApprove,
    this.onEdit,
    this.statusNameByCode,
    this.isRecallLoading = false,
    this.isCancelLoading = false,
    this.isSendApproveLoading = false,
  });

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
              SizedBox(height: 4.h),
              Divider(color: AppColors.grey, thickness: 1),
              SizedBox(height: 18.h),

              // Body: Thông tin chi tiết
              _buildInfoItem(
                icon: Icons.description,
                label: 'Phê duyệt',
                value: timeOff.appoveProcess ?? '',
              ),

              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'Ngày đăng ký',
                value: _formatDateTime(timeOff.dateReg),
              ),
              SizedBox(height: 12.h),

              _buildInfoItem(
                icon: Icons.label_outline,
                label: 'Lý do nghỉ',
                value: _formatVacationType(),
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.location_on,
                label: 'Nơi nghỉ',
                value: timeOff.domIntName ?? 'Không có',
              ),
              SizedBox(height: 12.h),
          if (timeOff.description != null && timeOff.description!.isNotEmpty) _buildInfoItem(
                icon: Icons.note,
                label: 'Mô tả chi tiết',
                value: timeOff.description ?? '',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          "Ngày nghỉ: ${_formatDateRange()}",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 12.w),
        // Status chip
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    final approveStatus = timeOff.approveStatus ?? '-';
    final statusText =
        statusNameByCode?[approveStatus] ?? timeOff.statusName ?? approveStatus;
    final colors = _statusColors(approveStatus);
    final bgColor = colors.$1;
    final textColor = colors.$2;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: textColor, width: 1),
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

  (Color, Color) _statusColors(String code) {
    switch (code) {
      case '--': // Chưa chuyển cho cán bộ phê duyệt
        return (const Color(0xFFF5F5F5), const Color(0xFF666666));
      case 'IN': // Đang trong quá trình phê duyệt
        return (const Color(0xFFFFF3E0), const Color.fromARGB(255, 250, 158, 65));
      case 'FN': // Được phê duyệt
        return (const Color(0xFFE0FFF3), const Color(0xFF00B894));
      case 'RJ': // Từ chối
        return (const Color(0xFFFFEBEE), const Color.fromARGB(255, 189, 2, 2));
      case 'BK': // Thu hồi
        return (const Color.fromARGB(255, 255, 238, 224), const Color.fromARGB(255, 238, 91, 6));
      default: // Fallback
        return (AppColors.primary.withOpacity(0.08), AppColors.primary);
    }
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,

      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '$label:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
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
    final StatusIn = approveStatus == 'IN';

    if (isDraft) {
      return Row(
        children: [
          if (onSendApprove != null && !statusXX) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: isSendApproveLoading ? null : onSendApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSendApproveLoading) ...[
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      isSendApproveLoading ? 'Đang gửi...' : 'Gửi phê duyệt',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                onPressed: isCancelLoading ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCancelLoading) ...[
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red.shade700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      isCancelLoading ? 'Đang hủy...' : 'Hủy',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Đơn "Chờ phê duyệt", "Đã phê duyệt": Thu hồi
    if (StatusIn) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isRecallLoading ? null : onRecall,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red.shade300, width: 1.5),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRecallLoading) ...[
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.red.shade600,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                isRecallLoading ? 'Đang thu hồi...' : 'Thu hồi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
            ],
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatVacationType() {
    return timeOff.vacationReasonName ?? '';
  }
}
