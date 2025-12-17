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

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeFunctionController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<HomeFunctionController>();

    return Obx(() {
      final hasCache = controller.sessions.isNotEmpty;

      // Loading state (chỉ show loader khi KHÔNG có cache)
      if (controller.isLoading.value && !hasCache) {
        // ✅ Không hiển thị spinner (tránh xấu UI khi hot restart/reload)
        return const SizedBox.shrink();
      }

      // Error state (ưu tiên cache: nếu có data thì vẫn hiển thị)
      if (controller.error.value.isNotEmpty && !hasCache) {
        print('❌ Home function error: ${controller.error.value}');
        return Container(
          padding: EdgeInsets.all(12.w),
          child: Center(
            child: Text(
              controller.error.value,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      // Empty state
      if (controller.sessions.isEmpty) {
        print('⚠️ Home function sessions list is empty');
        return const SizedBox.shrink();
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
