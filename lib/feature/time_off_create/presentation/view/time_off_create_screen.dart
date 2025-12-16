import 'package:flutter/material.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_form_controller.dart';
import 'package:vos_flutter/feature/time_off/presentation/view/time_off_form_screen.dart';

class TimeOffCreateScreen extends StatelessWidget {
  const TimeOffCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeOffFormScreen(
      appBarTitle: 'Tạo mới',
      controllerTag: TimeOffFormController.tagCreate,
      enableOpenUploaded: false,
      daysHeaderText: 'Số ngày nghỉ',
      daysTotalWidth: 153,
    );
  }
}
