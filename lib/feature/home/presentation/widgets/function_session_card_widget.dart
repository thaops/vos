import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/utils/responsive_helper.dart';
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

  // Helper để detect iPad/tablet
  bool _isTablet(BuildContext context) {
    if (kIsWeb) return false;
    if (Platform.isMacOS) return false;
    return ResponsiveHelper.isTablet(context) || 
           (Platform.isIOS && MediaQuery.of(context).size.shortestSide >= 600);
  }

  @override
  Widget build(BuildContext context) {
    final isMacOS = !kIsWeb && Platform.isMacOS;
    final isTablet = _isTablet(context);

    return Container(
      margin: EdgeInsets.only(bottom: (isMacOS || isTablet) ? 16.h : 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((isMacOS || isTablet) ? 12.r : 14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity((isMacOS || isTablet) ? 0.08 : 0.05),
            blurRadius: (isMacOS || isTablet) ? 12 : 10,
            offset: Offset(0, (isMacOS || isTablet) ? 3 : 2),
            spreadRadius: 0,
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
                horizontal: (isMacOS || isTablet) ? 20.w : 16.w,
                vertical: (isMacOS || isTablet) ? 16.h : 12.h,
              ),
              decoration: BoxDecoration(
                color: (isMacOS || isTablet) ? Colors.grey[50] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular((isMacOS || isTablet) ? 12.r : 14.r),
                  topRight: Radius.circular((isMacOS || isTablet) ? 12.r : 14.r),
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
                        fontSize: (isMacOS || isTablet) ? 17.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: (isMacOS || isTablet) ? 0.2 : 0,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: (isMacOS || isTablet) ? 26.sp : 24.sp,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey[300],
            indent: (isMacOS || isTablet) ? 20.w : 16.w,
            endIndent: (isMacOS || isTablet) ? 20.w : 16.w,
          ),
          // Function Items (chỉ hiển thị khi expanded)
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(
                left: (isMacOS || isTablet) ? 20.w : 16.w,
                right: (isMacOS || isTablet) ? 20.w : 16.w,
                top: (isMacOS || isTablet) ? 16.h : 12.h,
                bottom: (isMacOS || isTablet) ? 20.h : 12.h,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // số cột: iPad dùng 4 cột như macOS, mobile dùng 3 cột
                  final columns = (isMacOS || isTablet) ? 4 : 3;

                  // spacing giữa items
                  final spacing = (isMacOS || isTablet) ? 12.w : 8.w;

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
