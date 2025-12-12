import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/custom_select.dart';
import 'package:vos_flutter/feature/vacation/presentation/controller/vacation_controller.dart';
import 'package:vos_flutter/feature/vacation/presentation/widgets/vacation_card.dart';

class VacationScreen extends GetView<VacationController> {
  const VacationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(
        title: 'Phép cá nhân',
        isBack: true,
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: Obx(
              () => CustomSelect(
                name: controller.selectedYear.value.toString(),
                selectList: controller.yearList
                    .map(
                      (year) => Item(
                        id: year.toString(),
                        name: year.toString(),
                      ),
                    )
                    .toList(),
                selectedId: controller.selectedYear.value.toString(),
                selectedName: controller.selectedYear.value.toString(),
                onProjectSelected: (yearId) {
                  if (yearId != null) {
                    final year = int.tryParse(yearId);
                    if (year != null) {
                      controller.onYearChanged(year);
                    }
                  }
                },
                searchable: false,
              ),
            ),
          ),
          // List content
          Expanded(
            child: Obx(() {
              if (controller.status == ControllerStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.status == ControllerStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage,
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => controller.loadVacationList(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.vacationList.isEmpty) {
                return Center(
                  child: Text(
                    'Không có dữ liệu',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.vacationList.length,
                  itemBuilder: (context, index) {
                    final vacation = controller.vacationList[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: VacationCard(vacation: vacation),
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

