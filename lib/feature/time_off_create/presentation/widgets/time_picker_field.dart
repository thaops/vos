import 'package:flutter/material.dart';

class TimePickerField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;

  const TimePickerField({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  value ?? 'Chọn giờ',
                  style: TextStyle(
                    fontSize: 14,
                    color: value == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ),
              Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
