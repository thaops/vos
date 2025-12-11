import 'package:flutter/material.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool required;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateField = SizedBox(
      height: 48,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? 'Chọn ngày',
                  style: TextStyle(
                    fontSize: 14,
                    color: value == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ),
              Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );

    if (label.isEmpty) {
      return dateField;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextWidget(
              text: label,
              fontSize: 14,
              color: TimeOffCreateColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            if (required) ...[
              const SizedBox(width: 4),
              TextWidget(
                text: '*',
                fontSize: 14,
                color: TimeOffCreateColors.error,
                fontWeight: FontWeight.w500,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        dateField,
      ],
    );
  }
}
