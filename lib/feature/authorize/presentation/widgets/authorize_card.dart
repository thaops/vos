import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';

class AuthorizeCard extends StatelessWidget {
  const AuthorizeCard({
    super.key,
    required this.authorize,
    required this.onCancel,
    this.isCancelling = false,
  });

  final Authorize authorize;
  final VoidCallback onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText(authorize.status);
    final isActive = authorize.status == 'OK';

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    authorize.forFullName.isNotEmpty
                        ? authorize.forFullName
                        : '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0A0A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // SizedBox(width: 12.w),
                // Container(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: 12.w,
                //     vertical: 6.h,
                //   ),
                //   decoration: BoxDecoration(
                //     color: isActive
                //         ? const Color(0xFFE0FFF3)
                //         : Colors.grey.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(20.r),
                //   ),
                //   child: Text(
                //     statusText,
                //     style: TextStyle(
                //       fontSize: 12.sp,
                //       fontWeight: FontWeight.w600,
                //       color: isActive
                //           ? const Color(0xFF00B894)
                //           : Colors.grey[700],
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildInfoItemWithIcon(
              icon: Icons.calendar_today,
              label: 'Từ ngày đến ngày',
              value: _formatDateRange(authorize.fromDate, authorize.toDate),
            ),
            SizedBox(height: 16.h),
            _buildInfoItemWithIcon(
              icon: Icons.label_outline,
              label: 'Loại ủy quyền',
              value: authorize.lsAuthorize.isNotEmpty
                  ? authorize.lsAuthorize
                  : 'Chưa cập nhật',
            ),
            SizedBox(height: 16.h),
            if (authorize.description.isNotEmpty)
              _buildInfoItemWithIcon(
                icon: Icons.description_outlined,
                label: 'Mô tả quyền',
                value: authorize.description,
              ),
            if (authorize.description.isNotEmpty) SizedBox(height: 16.h),
            _buildInfoItemWithIcon(
              icon: Icons.access_time,
              label: 'Cập nhật cuối',
              value: _formatDateTime(authorize.recdate),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isCancelling || !isActive ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isActive
                          ? Colors.red.shade300
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCancelling) ...[
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
                        isActive
                            ? (isCancelling ? 'Đang hủy...' : 'Hủy ủy quyền')
                            : 'Đã hủy',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.red.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OK':
        return 'Hoạt động';
      case 'XX':
        return 'Hết hiệu lực';
      default:
        return status;
    }
  }

  String _formatDateRange(String fromDate, String toDate) {
    final from = _formatDate(fromDate);
    final isToDateNull = toDate.isEmpty || toDate == '1900-01-01T00:00:00';
    if (isToDateNull) {
      return from;
    }
    final to = _formatDate(toDate);
    return '$from - $to';
  }

  String _formatDateTime(String dateString) {
    if (dateString.isEmpty || dateString == '1900-01-01T00:00:00') {
      return 'Chưa cập nhật';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
    } catch (_) {
      return dateString;
    }
  }

  Widget _buildInfoItemWithIcon({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty || dateString == '1900-01-01T00:00:00') {
      return 'Không giới hạn';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}
