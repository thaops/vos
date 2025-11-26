import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthorizeFormFieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const AuthorizeFormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isRequired)
          Text(
            '* ',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

