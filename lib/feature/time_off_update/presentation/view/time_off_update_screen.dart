import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/custom_button.dart';
import 'package:vos_flutter/common/widgets/custom_text_field.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/date_picker_field.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/form_dropdown_field.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_picker_field.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/controller/time_off_update_controller.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/widgets/file_attachment_widget.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/widgets/user_info_block.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/widgets/work_code_list_widget.dart';

class TimeOffUpdateScreen extends GetView<TimeOffUpdateController> {
  const TimeOffUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimeOffCreateColors.bgColor,
      appBar: AppBarWidget(title: 'Cập nhật'),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth = constraints.maxWidth > 1100
                ? 1100.0
                : constraints.maxWidth;
            final isWide = maxContentWidth >= 820;
            final fieldWidth = isWide
                ? (maxContentWidth - 20) / 2
                : maxContentWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const UserInfoBlock(),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 20,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: FormDropdownField(
                              label: 'Lý do nghỉ',
                              required: true,
                              hint: 'Chọn loại phép',
                              options: controller.leaveTypeOptions,
                              selectedId: controller.selectedLeaveType,
                              onChanged: controller.onLeaveTypeChanged,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: FormDropdownField(
                              label: 'Nơi nghỉ',
                              hint: 'Chọn nơi nghỉ',
                              options: controller.leaveLocationOptions,
                              selectedId: controller.leaveLocation,
                              onChanged: controller.onLeaveLocationChanged,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    TextWidget(
                                      text: 'Ngày bắt đầu',
                                      fontSize: 14,
                                      color: TimeOffCreateColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    const SizedBox(width: 4),
                                    TextWidget(
                                      text: '*',
                                      fontSize: 14,
                                      color: TimeOffCreateColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Obx(
                                        () => DatePickerField(
                                          label: '',
                                          required: false,
                                          value:
                                              controller
                                                  .formattedFromDate
                                                  .isEmpty
                                              ? null
                                              : controller.formattedFromDate,
                                          onTap: () => controller
                                              .selectFromDate(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 1,
                                      child: Obx(
                                        () => TimePickerField(
                                          value:
                                              controller
                                                  .formattedFromTime
                                                  .isEmpty
                                              ? null
                                              : controller.formattedFromTime,
                                          onTap: () => controller
                                              .selectFromTime(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: 'Ngày kết thúc',
                                  fontSize: 14,
                                  color: TimeOffCreateColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Obx(
                                        () => DatePickerField(
                                          label: '',
                                          required: false,
                                          value:
                                              controller.formattedToDate.isEmpty
                                              ? null
                                              : controller.formattedToDate,
                                          onTap: () =>
                                              controller.selectToDate(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 1,
                                      child: Obx(
                                        () => TimePickerField(
                                          value:
                                              controller.formattedToTime.isEmpty
                                              ? null
                                              : controller.formattedToTime,
                                          onTap: () =>
                                              controller.selectToTime(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: const WorkCodeListWidget(),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildReasonTextArea(),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              'Thông tin liên lạc',
                              controller.contactInfoController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              'Địa chỉ',
                              controller.addressController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: FormDropdownField(
                              label: 'Trạng thái',
                              hint: 'Chọn trạng thái',
                              options: controller.statusOptions,
                              selectedId: controller.selectedStatus,
                              onChanged: controller.onStatusChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const FileAttachmentWidget(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: maxContentWidth,
                        child: _buildActionButtons(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReasonTextArea() {
    return Obx(() {
      final isRequired = controller.isReasonRequired;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextWidget(
                text: 'Mô tả chi tiết',
                fontSize: 14,
                color: TimeOffCreateColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Icon(Icons.error, size: 16, color: TimeOffCreateColors.error),
              ],
            ],
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: controller.reasonController,
            hintText: 'Nhập lý do nghỉ phép...',
            minLines: 5,
            maxLines: 6,
            paddingVertical: 0,
            paddingHorizontal: 0,
            borderRadius: 8,
            fontSize: 14,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: label,
          fontSize: 14,
          color: TimeOffCreateColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: CustomTextField(
            controller: controller,
            hintText: label,
            borderRadius: 8,
            fontSize: 14,
            paddingVertical: 0,
            paddingHorizontal: 0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Lưu & Gửi phê duyệt',
              color: TimeOffCreateColors.success,
              textColor: TimeOffCreateColors.white,
              height: 50,
              fontSize: 14,
              width: double.infinity,
              isLoading:
                  controller.isLoading, // ✅ Truyền isLoading từ controller
              onPressed: controller.isLoading ? null : controller.onSubmit,
            ),
          ),
          8.horizontalSpace,
          Expanded(
            child: CustomButton(
              text: 'Lưu',
              isOutlined: true,
              borderColor: TimeOffCreateColors.success,
              textColor: TimeOffCreateColors.success,
              height: 50,
              width: double.infinity,
              fontSize: 14,
              isLoading:
                  controller.isLoading, // ✅ Truyền isLoading từ controller
              onPressed: controller.isLoading ? null : controller.onSaveDraft,
            ),
          ),
        ],
      ),
    );
  }
}
