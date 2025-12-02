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
      final canDecrement = item.days > 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: _buildText(item.code)),
            Expanded(flex: 3, child: _buildText(item.name, maxLines: 2)),
            SizedBox(
              width: 100, // Width cố định cho phần counter
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCounterButton(
                    Icons.remove,
                    canDecrement ? () => controller.decrementDays(index) : null,
                    enabled: canDecrement,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 30, // Width cố định cho số
                    child: TextWidget(
                      text: item.days == item.days.toInt()
                          ? '${item.days.toInt()}' // Hiển thị số nguyên nếu là số nguyên
                          : '${item.days.toStringAsFixed(1)}', // Hiển thị 1 chữ số thập phân
                      fontSize: 16,
                      color: TimeOffCreateColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCounterButton(
                    Icons.add,
                    () => controller.incrementDays(index),
                    enabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildText(String text, {int? maxLines}) {
    return TextWidget(
      text: text,
      fontSize: 14,
      color: TimeOffCreateColors.textPrimary,
      fontWeight: FontWeight.w400,
      maxLines: maxLines,
    );
  }

  Widget _buildCounterButton(
    IconData icon,
    VoidCallback? onTap, {
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: enabled
                ? TimeOffCreateColors.primary
                : TimeOffCreateColors.borderColor,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled
              ? TimeOffCreateColors.primary
              : TimeOffCreateColors.textSecondary,
        ),
      ),
    );
  }
}
