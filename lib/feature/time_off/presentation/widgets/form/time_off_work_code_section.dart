import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/time_off/presentation/models/time_off_work_code_item.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class TimeOffWorkCodeSection extends StatelessWidget {
  final RxList<TimeOffWorkCodeItem> items;
  final void Function(int index) onIncrement;
  final void Function(int index) onDecrement;
  final void Function(int index, String value) onChangeDays;
  final String daysHeaderText;
  final double totalWidth;

  const TimeOffWorkCodeSection({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChangeDays,
    this.daysHeaderText = 'Ngày nghỉ',
    this.totalWidth = 150,
  });

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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: const BoxDecoration(
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
                  child: _buildHeaderText(daysHeaderText, center: true),
                ),
              ],
            ),
          ),
          Obx(() {
            final computedTotalDays = items.fold<double>(
              0.0,
              (sum, item) => sum + item.days,
            );

            return Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: TimeOffCreateColors.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: totalWidth.w,
                    child: TextWidget(
                      text: computedTotalDays == computedTotalDays.toInt()
                          ? '${computedTotalDays.toInt()}'
                          : computedTotalDays.toStringAsFixed(1),
                      fontSize: 18,
                      color: TimeOffCreateColors.primary,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: TimeOffCreateColors.dividerColor,
              ),
              itemBuilder: (_, index) => _TimeOffWorkCodeItemRow(
                item: items[index],
                onIncrement: () => onIncrement(index),
                onDecrement: () => onDecrement(index),
                onChangeDays: (value) => onChangeDays(index, value),
              ),
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

class _TimeOffWorkCodeItemRow extends StatelessWidget {
  final TimeOffWorkCodeItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onChangeDays;

  const _TimeOffWorkCodeItemRow({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChangeDays,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = item.days > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: _buildText(item.code)),
          Expanded(flex: 3, child: _buildText(item.name, maxLines: 2)),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCounterButton(
                  Icons.remove,
                  canDecrement ? onDecrement : null,
                  enabled: canDecrement,
                ),
                const SizedBox(width: 8),
                _DaysInputField(days: item.days, onChanged: onChangeDays),
                const SizedBox(width: 8),
                _buildCounterButton(Icons.add, onIncrement, enabled: true),
              ],
            ),
          ),
        ],
      ),
    );
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
  final double days;
  final ValueChanged<String> onChanged;

  const _DaysInputField({required this.days, required this.onChanged});

  @override
  State<_DaysInputField> createState() => _DaysInputFieldState();
}

class _DaysInputFieldState extends State<_DaysInputField> {
  late final TextEditingController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.days));
  }

  @override
  void didUpdateWidget(_DaysInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isUpdating || oldWidget.days == widget.days) return;
    final newText = _format(widget.days);
    if (_controller.text != newText) _controller.text = newText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double days) {
    return days == days.toInt() ? '${days.toInt()}' : days.toStringAsFixed(1);
  }

  TextInputFormatter _decimalInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;
      if (text.isEmpty) return newValue;

      // Cho phép số và một dấu chấm, tối đa 1 chữ số sau dấu chấm
      final regex = RegExp(r'^\d*\.?\d{0,1}$');
      if (regex.hasMatch(text)) {
        return newValue;
      }
      return oldValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_decimalInputFormatter()],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: TimeOffCreateColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: TimeOffCreateColors.borderColor,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: TimeOffCreateColors.borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
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
