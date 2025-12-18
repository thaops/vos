import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/home/presentation/controller/home_function_controller.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/function_session_card_widget.dart';

class HomeFunctionsSectionWidget extends StatefulWidget {
  final Function(String) onActionTap;

  const HomeFunctionsSectionWidget({super.key, required this.onActionTap});

  @override
  State<HomeFunctionsSectionWidget> createState() =>
      _HomeFunctionsSectionWidgetState();
}

class _HomeFunctionsSectionWidgetState
    extends State<HomeFunctionsSectionWidget> {
  // Map để quản lý trạng thái expand/collapse của các section
  final Map<String, bool> _expandedSections = {};

  /// ✅ Loading placeholder - hiển thị skeleton thay vì trắng hoàn toàn
  Widget _buildLoadingPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          // Skeleton cho section header
          _buildSkeletonCard(),
          SizedBox(height: 12.h),
          _buildSkeletonCard(),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton
          Container(
            width: 120.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 12.h),
          // Items row skeleton
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8.w : 0),
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Controller chưa sẵn sàng (hiếm khi xảy ra vì MainBinding đã đăng ký)
    if (!Get.isRegistered<HomeFunctionController>()) {
      return _buildLoadingPlaceholder();
    }

    final controller = Get.find<HomeFunctionController>();

    return Obx(() {
      final hasCache = controller.sessions.isNotEmpty;

      // Loading state (chỉ show loader khi KHÔNG có cache)
      if (controller.isLoading.value && !hasCache) {
        return _buildLoadingPlaceholder();
      }

      // Error state (ưu tiên cache: nếu có data thì vẫn hiển thị)
      if (controller.error.value.isNotEmpty && !hasCache) {
        print('❌ Home function error: ${controller.error.value}');
        return Container(
          padding: EdgeInsets.all(12.w),
          child: Center(
            child: Text(
              controller.error.value,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      // Empty state (đợi data load xong)
      if (controller.sessions.isEmpty) {
        print('⚠️ Home function sessions list is empty');
        return _buildLoadingPlaceholder();
      }

      print(
        '✅ Displaying ${controller.sessions.length} home function sessions',
      );

      // Sessions list
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.sessions.map((session) {
          final sessionKey = session.sessionName;
          final isExpanded = _expandedSections[sessionKey] ?? true;

          return FunctionSessionCardWidget(
            session: session,
            isExpanded: isExpanded,
            onToggleExpand: () {
              setState(() {
                _expandedSections[sessionKey] = !isExpanded;
              });
            },
            onActionTap: widget.onActionTap,
          );
        }).toList(),
      );
    });
  }
}
