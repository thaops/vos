import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/controller/time_off_update_controller.dart';

class UserInfoBlock extends GetView<TimeOffUpdateController> {
  const UserInfoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TimeOffCreateColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên', controller.userName.value),
            const SizedBox(height: 6),
            _buildInfoRow('Chức danh', controller.userPosition.value),
            const SizedBox(height: 6),
            _buildInfoRow('Đơn vị', controller.userDepartment.value),
            const SizedBox(height: 6),
            _buildInfoRow('Tồn phép', '${controller.remainingLeave.value}'),
            const SizedBox(height: 6),
            _buildInfoRow('Tồn OT', '${controller.remainingOT.value}'),
            const SizedBox(height: 6),
            _buildInfoRow('Phép đã nghỉ', '${controller.pendingLeave.value}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: TextWidget(
            text: '$label:',
            fontSize: 14,
            color: TimeOffCreateColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: TextWidget(
            text: value,
            fontSize: 14,
            color: TimeOffCreateColors.textPrimary,
            fontWeight: FontWeight.w600,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
