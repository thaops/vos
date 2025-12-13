import 'package:get/get.dart';
import 'package:vos_flutter/feature/time_off/presentation/models/time_off_work_code_item.dart';

mixin TimeOffFormWorkCodeMixin {
  RxList<TimeOffWorkCodeItem> get workCodeList;

  double get totalDays {
    return workCodeList.fold(0.0, (sum, item) => sum + item.days);
  }

  void incrementDays(int index) {
    if (index < workCodeList.length) {
      workCodeList[index].days += 0.5;
      workCodeList.refresh();
    }
  }

  void decrementDays(int index) {
    if (index < workCodeList.length && workCodeList[index].days > 0) {
      workCodeList[index].days -= 0.5;
      workCodeList.refresh();
    }
  }

  void updateDays(int index, String value) {
    if (index >= workCodeList.length) return;
    final parsedValue = double.tryParse(value);
    if (parsedValue != null && parsedValue >= 0) {
      workCodeList[index].days = parsedValue;
      workCodeList.refresh();
      return;
    }
    if (value.isEmpty) {
      workCodeList[index].days = 0.0;
      workCodeList.refresh();
    }
  }
}


