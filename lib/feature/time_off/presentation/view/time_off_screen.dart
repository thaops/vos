import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_controller.dart';
import 'package:vos_flutter/feature/time_off/presentation/widgets/time_off_card.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/router/app_router.dart';

class TimeOffScreen extends GetView<TimeOffController> {
  const TimeOffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(
        title: 'Đơn nghỉ phép',
        iconRightfirst: Icons.add,
        functionfirst: () async {
          final result = await Get.toNamed(AppRouter.timeOffCreate);
          // Nếu submit thành công (result = true), reload data
          if (result == true) {
            controller.loadTimeOffList();
          }
        },
      ),
      body: Obx(() {
        final data = controller.timeOffList;
        if (data.isEmpty && controller.status == ControllerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (data.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return TimeOffCard(
                timeOff: item,
                onCancel: () => controller.cancelTimeOff(item),
              );
            },
          ),
        );
      }),
    );
  }
}
