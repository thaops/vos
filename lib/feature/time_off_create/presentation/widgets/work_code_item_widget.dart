import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/controller/time_off_create_controller.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class WorkCodeItemWidget extends GetView<TimeOffCreateController> {
  final int index;

  const WorkCodeItemWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.workCodeList[index];
      final isSelected = item.days > 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(flex: 2, child: _buildText(item.code)),
            Expanded(flex: 3, child: _buildText(item.name)),
            Expanded(
              flex: 2,
              child: isSelected
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCounterButton(
                          Icons.remove,
                          () => controller.decrementDays(index),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TextWidget(
                            text: '${item.days}',
                            fontSize: 16,
                            color: TimeOffCreateColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCounterButton(
                          Icons.add,
                          () => controller.incrementDays(index),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => controller.incrementDays(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: TimeOffCreateColors.borderColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextWidget(
                          text: 'Chọn',
                          fontSize: 14,
                          color: TimeOffCreateColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildText(String text) {
    return TextWidget(
      text: text,
      fontSize: 14,
      color: TimeOffCreateColors.textPrimary,
      fontWeight: FontWeight.w400,
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: TimeOffCreateColors.primary,
            width: 1.5,
          ),
        ),
        child: Icon(icon, size: 18, color: TimeOffCreateColors.primary),
      ),
    );
  }
}

