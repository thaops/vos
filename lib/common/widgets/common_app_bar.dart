import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onAddPressed;
  final String? addButtonTooltip;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onAddPressed,
    this.addButtonTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      actions: onAddPressed != null
          ? [
              Container(
                width: 24.w,
                height: 24.h,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(width: 1, color: AppColors.bacgroundApp),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onAddPressed,
                  tooltip: addButtonTooltip,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
