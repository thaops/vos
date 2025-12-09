import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/widgets/custom_select.dart';
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
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: Obx(
              () => Row(
                children: [
                  // Dropdown năm (flex: 1)
                  Expanded(
                    flex: 1,
                    child: CustomSelect(
                      name: controller.selectedYearId.value.isEmpty
                          ? 'Chọn năm'
                          : controller.selectedYearId.value,
                      selectList: controller.yearList
                          .map(
                            (year) => Item(
                              id: year.toString(),
                              name: year.toString(),
                            ),
                          )
                          .toList(),
                      selectedId: controller.selectedYearId.value.isEmpty
                          ? null
                          : controller.selectedYearId.value,
                      selectedName: controller.selectedYearId.value.isEmpty
                          ? null
                          : controller.selectedYearId.value,
                      onProjectSelected: controller.onYearFilterChanged,
                      searchable: false,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Dropdown trạng thái (flex: 2)
                  Expanded(
                    flex: 2,
                    child: CustomSelect(
                      name: controller.selectedStatusFilter.value.isEmpty
                          ? 'Chọn trạng thái'
                          : controller.selectedStatusFilter.value,
                      selectList: TimeOffController.statusFilterList
                          .map(
                            (filter) => Item(
                              id: filter['code']!,
                              name: filter['name']!,
                            ),
                          )
                          .toList(),
                      selectedId: controller.selectedStatusCode.value.isEmpty
                          ? null
                          : controller.selectedStatusCode.value,
                      selectedName:
                          controller.selectedStatusFilter.value.isEmpty
                          ? null
                          : controller.selectedStatusFilter.value,
                      onProjectSelected: controller.onStatusFilterChanged,
                      searchable: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List content
          Expanded(
            child: Obx(() {
              final data = controller.timeOffList;
              if (data.isEmpty &&
                  controller.status == ControllerStatus.loading) {
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
                      onCancel: controller.canCancel(item)
                          ? () => controller.cancelTimeOff(item)
                          : null,
                      onRecall: controller.isDraft(item)
                          ? () => controller.recallTimeOff(item)
                          : null,
                      onSendApprove: controller.isDraft(item)
                          ? () => controller.sendApproveRequest(item)
                          : null,
                      onEdit: controller.isDraft(item)
                          ? () => controller.navigateToUpdate(item)
                          : null,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
