import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_form_controller.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class TimeOffUserInfoBlock extends StatelessWidget {
  final String? controllerTag;

  const TimeOffUserInfoBlock({super.key, this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimeOffFormController>(tag: controllerTag);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TimeOffCreateColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() {
        final vacation = controller.personalVacation.value;
        final isLoading = controller.status == ControllerStatus.loading;

        if (controller.mode == TimeOffFormMode.create &&
            isLoading &&
            vacation == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final name = vacation?.fullName.isNotEmpty == true
            ? vacation!.fullName
            : (controller.userName.value.isEmpty
                  ? '-'
                  : controller.userName.value);
        final position = vacation?.jobTitleNameVN.isNotEmpty == true
            ? vacation!.jobTitleNameVN
            : (controller.userPosition.value.isEmpty
                  ? '-'
                  : controller.userPosition.value);
        final department = vacation?.departmentName.isNotEmpty == true
            ? vacation!.departmentName
            : (controller.userDepartment.value.isEmpty
                  ? '-'
                  : controller.userDepartment.value);

        final leaveRemain =
            vacation?.paidLeaveRemain ?? controller.remainingLeave.value;
        final otRemain =
            vacation?.overTimeRemain ?? controller.remainingOT.value;
        final leaveUsed = controller.mode == TimeOffFormMode.create
            ? (vacation?.paidLeaveUsedTotal ??
                  controller.paidLeaveUsedTotal.value)
            : (vacation?.paidLeaveUsedTotal ?? controller.pendingLeave.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên', name),
            const SizedBox(height: 6),
            _buildInfoRow('Chức danh', position),
            const SizedBox(height: 6),
            _buildInfoRow('Đơn vị', department),
            const SizedBox(height: 6),
            _buildInfoRow('Tồn phép', '$leaveRemain'),
            const SizedBox(height: 6),
            _buildInfoRow('Tồn OT', '$otRemain'),
            const SizedBox(height: 6),
            _buildInfoRow('Phép đã nghỉ', '$leaveUsed'),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150.w,
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
