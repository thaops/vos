import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/feature/home/domain/models/home_function.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/function_item_widget.dart';

class FunctionSessionCardWidget extends StatelessWidget {
  final HomeFunctionSession session;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final Function(String) onActionTap;

  const FunctionSessionCardWidget({
    super.key,
    required this.session,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMacOS = !kIsWeb && Platform.isMacOS;

    return Container(
      margin: EdgeInsets.only(bottom: isMacOS ? 16.h : 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMacOS ? 12.r : 14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isMacOS ? 0.08 : 0.05),
            blurRadius: isMacOS ? 12 : 10,
            offset: Offset(0, isMacOS ? 3 : 2),
            spreadRadius: isMacOS ? 0 : 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggleExpand,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMacOS ? 20.w : 16.w,
                vertical: isMacOS ? 16.h : 12.h,
              ),
              decoration: BoxDecoration(
                color: isMacOS ? Colors.grey[50] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMacOS ? 12.r : 14.r),
                  topRight: Radius.circular(isMacOS ? 12.r : 14.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      session.sessionName.isNotEmpty
                          ? session.sessionName
                          : 'Chức năng',
                      style: TextStyle(
                        fontSize: isMacOS ? 17.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: isMacOS ? 0.2 : 0,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: isMacOS ? 26.sp : 24.sp,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey[300],
            indent: isMacOS ? 20.w : 16.w,
            endIndent: isMacOS ? 20.w : 16.w,
          ),
          // Function Items (chỉ hiển thị khi expanded)
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(
                left: isMacOS ? 20.w : 16.w,
                right: isMacOS ? 20.w : 16.w,
                top: isMacOS ? 16.h : 12.h,
                bottom: isMacOS ? 20.h : 12.h,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // số cột
                  final columns = isMacOS ? 4 : 3;

                  // spacing giữa items
                  final spacing = isMacOS ? 12.w : 8.w;

                  // tính width cho mỗi item
                  final totalSpacing = spacing * (columns - 1);
                  final itemWidth =
                      (constraints.maxWidth - totalSpacing) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: session.listItems.map((item) {
                      return SizedBox(
                        width: itemWidth,
                        child: FunctionItemWidget(
                          item: item,
                          onActionTap: onActionTap,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
