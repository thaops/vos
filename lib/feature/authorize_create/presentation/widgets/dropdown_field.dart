import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DropdownField<T> extends StatelessWidget {
  final TextEditingController controller;
  final T? value;
  final String hint;
  final List<Map<String, String>> items;
  final String Function(Map<String, String>) displayText;
  final T Function(Map<String, String>) getValue;
  final Function(T?) onChanged;

  const DropdownField({
    super.key,
    required this.controller,
    required this.value,
    required this.hint,
    required this.items,
    required this.displayText,
    required this.getValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      final selectedItem = items.firstWhere(
        (item) => getValue(item) == value,
        orElse: () => <String, String>{},
      );
      if (selectedItem.isNotEmpty) {
        final displayValue = displayText(selectedItem);
        if (controller.text != displayValue) {
          controller.text = displayValue;
        }
      }
    } else if (controller.text.isNotEmpty) {
      controller.clear();
    }

    return TypeAheadField<Map<String, String>>(
      controller: controller,
      builder: (context, textController, focusNode) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF999999),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: _buildBorder(),
            enabledBorder: _buildBorder(),
            focusedBorder: _buildBorder(),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 20.sp,
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
          onTap: () {
            textController.clear();
            focusNode.requestFocus();
          },
        );
      },
      suggestionsCallback: (pattern) async => items,
      itemBuilder: (context, item) {
        final itemValue = getValue(item);
        final isSelected = value == itemValue;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText(item),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF222222),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: Colors.blue, size: 20.sp),
            ],
          ),
        );
      },
      onSelected: (item) {
        final itemValue = getValue(item);
        controller.text = displayText(item);
        onChanged(itemValue);
      },
      constraints: BoxConstraints(maxHeight: 300.h),
      decorationBuilder: (context, child) => Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        child: child,
      ),
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    );
  }
}

