import 'package:flutter/material.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_form_controller.dart';
import 'package:vos_flutter/feature/time_off/presentation/view/time_off_form_screen.dart';

class TimeOffUpdateScreen extends StatelessWidget {
  const TimeOffUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeOffFormScreen(
      appBarTitle: 'Cập nhật',
      controllerTag: TimeOffFormController.tagUpdate,
      enableOpenUploaded: true,
      daysHeaderText: 'Số ngày nghỉ',
    );
  }
}
