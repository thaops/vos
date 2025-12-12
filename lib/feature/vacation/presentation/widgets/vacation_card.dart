import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';

class VacationCard extends StatelessWidget {
  final Vacation vacation;

  const VacationCard({
    super.key,
    required this.vacation,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: vacation.statusColor,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tên và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (vacation.fullName != null)
                        Text(
                          vacation.fullName!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (vacation.jobTitleName != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          vacation.jobTitleName!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: vacation.statusColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    vacation.statusName ?? vacation.approveStatus ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            // Thông tin phép
            _buildInfoRow('Từ ngày', _formatDate(vacation.fromDate)),
            SizedBox(height: 8.h),
            _buildInfoRow('Đến ngày', _formatDate(vacation.toDate)),
            SizedBox(height: 8.h),
            if (vacation.domIntName != null)
              _buildInfoRow('Loại nghỉ', vacation.domIntName!),
            if (vacation.vacationReasonName != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Lý do', vacation.vacationReasonName!),
            ],
            if (vacation.description != null && vacation.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Mô tả', vacation.description!),
            ],
            if (vacation.appoveProcess != null && vacation.appoveProcess!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Quy trình', vacation.appoveProcess!),
            ],
            if (vacation.phepTon != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Tồn phép', '${vacation.phepTon!.toStringAsFixed(1)} ngày'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

