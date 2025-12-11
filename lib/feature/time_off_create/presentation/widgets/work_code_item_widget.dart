import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              width: 120, // Tăng width để chứa TextField
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCounterButton(
                    Icons.remove,
                    canDecrement ? () => controller.decrementDays(index) : null,
                    enabled: canDecrement,
                  ),
                  const SizedBox(width: 8),
                  _DaysInputField(
                    index: index,
                    days: item.days,
                    onChanged: (value) => controller.updateDays(index, value),
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

class _DaysInputField extends StatefulWidget {
  final int index;
  final double days;
  final Function(String) onChanged;

  const _DaysInputField({
    required this.index,
    required this.days,
    required this.onChanged,
  });

  @override
  State<_DaysInputField> createState() => _DaysInputFieldState();
}

class _DaysInputFieldState extends State<_DaysInputField> {
  late TextEditingController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.days == widget.days.toInt()
          ? '${widget.days.toInt()}'
          : widget.days.toStringAsFixed(1),
    );
  }

  @override
  void didUpdateWidget(_DaysInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUpdating && oldWidget.days != widget.days) {
      final newText = widget.days == widget.days.toInt()
          ? '${widget.days.toInt()}'
          : widget.days.toStringAsFixed(1);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
        ],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: TimeOffCreateColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: TimeOffCreateColors.borderColor,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: TimeOffCreateColors.borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: TimeOffCreateColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          isDense: true,
        ),
        onChanged: (value) {
          _isUpdating = true;
          widget.onChanged(value);
          _isUpdating = false;
        },
      ),
    );
  }
}
