import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/utils/date_utils.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class TimeOffCard extends StatelessWidget {
  final TimeOff timeOff;
  final VoidCallback? onCancel;

  const TimeOffCard({super.key, required this.timeOff, this.onCancel});

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
              label: 'Lý do',
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

            // Footer: Nút Hủy đơn
            if (timeOff.canCancel) ...[
              SizedBox(height: 16.h),
              _buildCancelButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isActive =
        timeOff.approveStatus == 'OK' ||
        timeOff.statusName?.contains('Đã phê duyệt') == true;

    return Row(
      children: [
        // Date range
        Expanded(
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
        _buildStatusChip(isActive),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final statusText =
        timeOff.statusName ??
        (timeOff.approveStatus == 'OK' ? 'Đã phê duyệt' : 'Đang xử lý');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFE0FFF3)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF00B894) : Colors.grey[700],
        ),
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

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
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
          'Hủy đơn',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade600,
          ),
        ),
      ),
    );
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
    return DateUtilsCustom.formatStringDate(
      date.toIso8601String(),
      isHour: true,
    );
  }

  String _formatVacationType() {
    if (timeOff.details == null || timeOff.details!.isEmpty) {
      return timeOff.vacationReasonName ?? 'Không có';
    }

    final types = timeOff.details!
        .map((d) => '${d.jobName}: ${d.soLuong} ngày')
        .join(', ');

    return types;
  }
}
