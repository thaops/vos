import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/custom_button.dart';
import 'package:vos_flutter/common/widgets/custom_text_field.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/form_dropdown_field.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/controller/time_off_update_controller.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const UserInfoBlock(),
              const SizedBox(height: 20),
              FormDropdownField(
                label: 'Loại phép',
                required: true,
                hint: 'Chọn loại phép',
                options: controller.leaveTypeOptions,
                selectedId: controller.selectedLeaveType,
                onChanged: controller.onLeaveTypeChanged,
              ),
              const SizedBox(height: 20),
              const WorkCodeListWidget(),
              const SizedBox(height: 20),
              _buildReasonTextArea(),
              const SizedBox(height: 20),
              FormDropdownField(
                label: 'Nơi nghỉ',
                hint: 'Chọn nơi nghỉ',
                options: controller.leaveLocationOptions,
                selectedId: controller.leaveLocation,
                onChanged: controller.onLeaveLocationChanged,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Thông tin liên lạc',
                controller.contactInfoController,
              ),
              const SizedBox(height: 20),
              _buildTextField('Địa chỉ', controller.addressController),
              const SizedBox(height: 16),
              FormDropdownField(
                label: 'Trạng thái',
                hint: 'Chọn trạng thái',
                options: controller.statusOptions,
                selectedId: controller.selectedStatus,
                onChanged: controller.onStatusChanged,
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTextArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Lý do',
          fontSize: 14,
          color: TimeOffCreateColors.textSecondary,
          fontWeight: FontWeight.w500,
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
