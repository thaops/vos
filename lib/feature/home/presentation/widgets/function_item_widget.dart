import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/home/domain/models/home_function.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail_args.dart';
import 'package:vos_flutter/router/app_router.dart';

class FunctionItemWidget extends StatelessWidget {
  final HomeFunctionItem item;
  final Function(String) onActionTap;

  const FunctionItemWidget({
    super.key,
    required this.item,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMacOS = !kIsWeb && Platform.isMacOS;
    
    Color itemColor;
    try {
      itemColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      itemColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        // Handle tap action based on type
        if (item.type == 'WEB' && item.actionUrl.isNotEmpty) {
          // Navigate to news detail screen with URL
          Get.toNamed(
            AppRouter.newsDetail,
            arguments: NewsDetailArgs(url: item.actionUrl, title: item.title),
          );
        } else if (item.action.isNotEmpty) {
          onActionTap(item.action);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMacOS ? 4.w : 4.w,
          vertical: isMacOS ? 8.h : 8.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon tròn lớn với nền màu xanh nhạt
            Container(
              width: isMacOS ? 52.w : 48.w,
              height: isMacOS ? 52.w : 48.w,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(isMacOS ? 0.12 : 0.15),
                shape: BoxShape.circle,
                boxShadow: isMacOS
                    ? [
                        BoxShadow(
                          color: itemColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: item.imageUrl.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(
                              Icons.apps,
                              color: itemColor,
                              size: isMacOS ? 32.sp : 28.sp,
                            ),
                      ),
                    )
                  : Icon(
                      Icons.apps,
                      color: itemColor,
                      size: isMacOS ? 32.sp : 28.sp,
                    ),
            ),
            SizedBox(height: isMacOS ? 10.h : 8.h),
            // Title
            Flexible(
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMacOS ? 13.sp : 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
