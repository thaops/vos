import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/controller/time_off_update_controller.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/widgets/work_code_item_widget.dart';

class WorkCodeListWidget extends GetView<TimeOffUpdateController> {
  const WorkCodeListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TimeOffCreateColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderText('Mã công')),
                Expanded(flex: 3, child: _buildHeaderText('Tên')),
                Expanded(
                  flex: 2,
                  child: _buildHeaderText('Ngày nghỉ', center: true),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: TimeOffCreateColors.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextWidget(
                    text: '',
                    fontSize: 14,
                    color: TimeOffCreateColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  Spacer(),
                  SizedBox(
                    width: 150.w,
                    child: TextWidget(
                      text: controller.totalDays == controller.totalDays.toInt()
                          ? '${controller.totalDays.toInt()}'
                          : '${controller.totalDays.toStringAsFixed(1)}',
                      fontSize: 18,
                      color: TimeOffCreateColors.primary,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.workCodeList.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: TimeOffCreateColors.dividerColor,
              ),
              itemBuilder: (_, index) => WorkCodeItemWidget(index: index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {bool center = false}) {
    return TextWidget(
      text: text,
      fontSize: 14,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
      textAlign: center ? TextAlign.center : TextAlign.left,
    );
  }
}
