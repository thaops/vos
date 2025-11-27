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
          // Function Items Grid (chỉ hiển thị khi expanded)
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
                  final itemCount = session.listItems.length;
                  
                  // Nếu có ít items (≤2), dùng Row để không chiếm quá nhiều không gian
                  if (itemCount <= 2) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: session.listItems.map((item) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMacOS ? 12.w : 8.w,
                            ),
                            child: FunctionItemWidget(
                              item: item,
                              onActionTap: onActionTap,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  
                  // Tính số cột dựa trên chiều rộng màn hình cho nhiều items
                  final screenWidth = MediaQuery.of(context).size.width;
                  int crossAxisCount = 3;
                  
                  // Trên macOS hoặc màn hình lớn, tăng số cột
                  if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
                    if (screenWidth > 1200) {
                      crossAxisCount = 6;
                    } else if (screenWidth > 800) {
                      crossAxisCount = 4;
                    } else {
                      crossAxisCount = 3;
                    }
                  } else {
                    // Mobile: giữ nguyên 3 cột
                    crossAxisCount = 3;
                  }
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isMacOS ? 12.w : 8.w,
                      mainAxisSpacing: isMacOS ? 12.h : 8.h,
                      childAspectRatio: isMacOS ? 0.95 : 1.0,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final item = session.listItems[index];
                      return FunctionItemWidget(
                        item: item,
                        onActionTap: onActionTap,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
