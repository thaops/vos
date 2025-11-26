import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatePickerField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Chọn',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isPlaceholder
                      ? const Color(0xFF999999)
                      : const Color(0xFF222222),
                  fontWeight:
                      isPlaceholder ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20.sp),
          ],
        ),
      ),
    );
  }
}

