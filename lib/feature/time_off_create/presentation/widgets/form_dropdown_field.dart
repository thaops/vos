import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/custom_select.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class FormDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final RxList<String> options;
  final RxString selectedId;
  final Function(String?) onChanged;
  final bool required;

  const FormDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextWidget(
              text: label,
              fontSize: 14,
              color: TimeOffCreateColors.textPrimary,
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
        Obx(
          () => CustomSelect(
            name: hint,
            selectList: options.map((e) => Item(id: e, name: e)).toList(),
            selectedId: selectedId.value.isEmpty ? null : selectedId.value,
            selectedName: selectedId.value.isEmpty ? null : selectedId.value,
            onProjectSelected: onChanged,
          ),
        ),
      ],
    );
  }
}
