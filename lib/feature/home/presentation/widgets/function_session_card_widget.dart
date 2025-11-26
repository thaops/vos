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
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggleExpand,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      session.sessionName.isNotEmpty
                          ? session.sessionName
                          : 'Chức năng',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: Colors.grey[300]),
          // Function Items Grid (chỉ hiển thị khi expanded)
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 0,
                bottom: 12.h,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.2,
                ),
                itemCount: session.listItems.length,
                itemBuilder: (context, index) {
                  final item = session.listItems[index];
                  return FunctionItemWidget(
                    item: item,
                    onActionTap: onActionTap,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
