import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/custom_button.dart';
import 'package:vos_flutter/common/widgets/custom_text_field.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_form_controller.dart';
import 'package:vos_flutter/feature/time_off/presentation/widgets/form/time_off_file_attachment_section.dart';
import 'package:vos_flutter/feature/time_off/presentation/widgets/form/time_off_user_info_block.dart';
import 'package:vos_flutter/feature/time_off/presentation/widgets/form/time_off_work_code_section.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/date_picker_field.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/form_dropdown_field.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_picker_field.dart';

class TimeOffFormScreen extends GetView<TimeOffFormController> {
  final String appBarTitle;
  final String controllerTag;
  final bool enableOpenUploaded;

  final String daysHeaderText;
  final double daysTotalWidth;

  final GlobalKey _leaveTypeKey = GlobalKey();
  final GlobalKey _reasonKey = GlobalKey();

  TimeOffFormScreen({
    super.key,
    required this.appBarTitle,
    required this.controllerTag,
    required this.enableOpenUploaded,
    required this.daysHeaderText,
    required this.daysTotalWidth,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimeOffCreateColors.bgColor,
      appBar: AppBarWidget(title: appBarTitle),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                      TimeOffUserInfoBlock(controllerTag: controllerTag),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 20,
                        children: [
                          SizedBox(
                            key: _leaveTypeKey,
                            width: fieldWidth,
                            child: FormDropdownField(
                              label: 'Lý do nghỉ',
                              required: true,
                              hint: 'Chọn loại',
                              options: controller.leaveTypeOptions,
                              selectedId: controller.selectedLeaveType,
                              onChanged: controller.onLeaveTypeChanged,
                              errorText: controller.leaveTypeError.value,
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
                            key: _reasonKey,
                            width: fieldWidth,
                            child: _buildReasonTextArea(),
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
                            child: TimeOffWorkCodeSection(
                              items: controller.workCodeList,
                              onIncrement: controller.incrementDays,
                              onDecrement: controller.decrementDays,
                              onChangeDays: controller.updateDays,
                              daysHeaderText: daysHeaderText,
                              totalWidth: daysTotalWidth,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              'Thông tin liên lạc',
                              controller.contactInfoController,
                              minLines: 5,
                              maxLines: 5,
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
                      TimeOffFileAttachmentSection(
                        attachedFiles: controller.attachedFiles,
                        uploadedFiles: controller.uploadedFiles,
                        isUploading: controller.isUploading,
                        onFilesSelected: controller.onFilesSelected,
                        onUploadAll: controller.uploadFiles,
                        onRemoveLocalFile: controller.removeFile,
                        onRemoveUploadedFile: controller.removeUploadedFile,
                        enableOpenUploaded: enableOpenUploaded,
                      ),
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
              if (isRequired) ...[
                TextWidget(
                  text: '*',
                  fontSize: 14,
                  color: TimeOffCreateColors.error,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(width: 4),
              ],
              TextWidget(
                text: 'Mô tả chi tiết',
                fontSize: 14,
                color: TimeOffCreateColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: controller.reasonController,
            hintText: 'Mô tả lý do nghỉ phép...',
            textCapitalization: TextCapitalization.sentences,
            minLines: 5,
            maxLines: 6,
            paddingVertical: 0,
            paddingHorizontal: 0,
            borderRadius: 8,
            fontSize: 14,
            error: controller.reasonError.value,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int minLines = 1,
    int maxLines = 1,
  }) {
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
        if (minLines == 1 && maxLines == 1)
          SizedBox(
            height: 48,
            child: CustomTextField(
              controller: controller,
              hintText: label,
              textCapitalization: TextCapitalization.sentences,
              borderRadius: 8,
              fontSize: 14,
              paddingVertical: 0,
              paddingHorizontal: 0,
              minLines: minLines,
              maxLines: maxLines,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          )
        else
          CustomTextField(
            controller: controller,
            hintText: label,
            textCapitalization: TextCapitalization.sentences,
            borderRadius: 8,
            fontSize: 14,
            paddingVertical: 0,
            paddingHorizontal: 0,
            minLines: minLines,
            maxLines: maxLines,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
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
              isLoading: controller.isLoading,
              onPressed: controller.isLoading ? null : _handleSubmit,
            ),
          ),
          8.horizontalSpace,
          Expanded(
            child: CustomButton(
              text: 'Lưu tạm',
              isOutlined: true,
              borderColor: TimeOffCreateColors.success,
              textColor: TimeOffCreateColors.success,
              height: 50,
              width: double.infinity,
              fontSize: 14,
              isLoading: controller.isLoading,
              onPressed: controller.isLoading ? null : _handleSaveDraft,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final firstError = controller.validateForSubmit();
    if (firstError != null) {
      _scrollToFirstError(firstError);
      return;
    }
    await controller.submit();
  }

  Future<void> _handleSaveDraft() async {
    final firstError = controller.validateForDraft();
    if (firstError != null) {
      _scrollToFirstError(firstError);
      return;
    }
    await controller.saveDraft();
  }

  void _scrollToFirstError(TimeOffFormFieldError error) {
    final key = switch (error) {
      TimeOffFormFieldError.leaveType => _leaveTypeKey,
      TimeOffFormFieldError.reason => _reasonKey,
    };

    final ctx = key.currentContext;
    if (ctx == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    });
  }
}
