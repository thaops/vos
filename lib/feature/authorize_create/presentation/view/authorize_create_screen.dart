import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/controller/authorize_create_controller.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/widgets/authorize_form_field_label.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/widgets/date_picker_field.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/widgets/delegate_search_field.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/widgets/dropdown_field.dart';

class AuthorizeCreateScreen extends GetView<AuthorizeCreateController> {
  const AuthorizeCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(title: 'Tạo mới'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 900
              ? 900.0
              : constraints.maxWidth;
          final isWide = maxContentWidth >= 720;
          final fieldWidth = isWide
              ? (maxContentWidth - 16) / 2
              : maxContentWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 16.h,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthorizeFormFieldLabel(
                                label: 'Người được ủy quyền',
                                isRequired: true,
                              ),
                              SizedBox(height: 8.h),
                              const DelegateSearchField(),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthorizeFormFieldLabel(
                                label: 'Từ ngày',
                                isRequired: true,
                              ),
                              SizedBox(height: 8.h),
                              Obx(
                                () => DatePickerField(
                                  value: controller.formattedFromDate,
                                  onTap: () => _selectFromDate(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthorizeFormFieldLabel(
                                label: 'Đến ngày',
                                isRequired: false,
                              ),
                              SizedBox(height: 8.h),
                              Obx(
                                () => DatePickerField(
                                  value: controller.formattedToDate,
                                  onTap: () => _selectToDate(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthorizeFormFieldLabel(
                                label: 'Loại ủy quyền',
                                isRequired: true,
                              ),
                              SizedBox(height: 8.h),
                              Obx(
                                () => DropdownField<String>(
                                  controller:
                                      controller.authorizeTypeController,
                                  value: controller.selectedAuthorizeType.value,
                                  hint: 'Chọn',
                                  items: controller.authorizeTypes,
                                  displayText: (item) => item['name'] ?? '',
                                  getValue: (item) => item['code'] ?? '',
                                  onChanged: controller.selectAuthorizeType,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthorizeFormFieldLabel(
                                label: 'Trạng thái',
                                isRequired: true,
                              ),
                              SizedBox(height: 8.h),
                              Obx(
                                () => DropdownField<String>(
                                  controller: controller.statusController,
                                  value: controller.selectedStatus.value,
                                  hint: 'Chọn',
                                  items: controller.statuses,
                                  displayText: (item) => item['name'] ?? '',
                                  getValue: (item) => item['code'] ?? '',
                                  onChanged: controller.selectStatus,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Obx(
                      () => SizedBox(
                        width: maxContentWidth,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.createAuthorize,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AA55),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSubmitting.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Lưu',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final initial =
        controller.fromDate.value ??
        DateTime.now().add(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // Chọn giờ, mặc định 00:00 nếu chưa có
    final existing = controller.fromDate.value;
    final initialTime = existing != null
        ? TimeOfDay.fromDateTime(existing)
        : const TimeOfDay(hour: 0, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    final time = pickedTime ?? initialTime;
    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      time.hour,
      time.minute,
    );

    await controller.selectFromDate(dateTime);
  }

  Future<void> _selectToDate(BuildContext context) async {
    final base =
        controller.toDate.value ?? controller.fromDate.value ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: controller.fromDate.value ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // Chọn giờ, mặc định 23:59 nếu chưa có
    final existing = controller.toDate.value;
    final initialTime = existing != null
        ? TimeOfDay.fromDateTime(existing)
        : const TimeOfDay(hour: 23, minute: 59);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    final time = pickedTime ?? initialTime;
    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      time.hour,
      time.minute,
    );

    await controller.selectToDate(dateTime);
  }
}
