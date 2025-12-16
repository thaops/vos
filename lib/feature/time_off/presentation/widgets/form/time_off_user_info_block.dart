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

    return Obx(() {
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
      final otRemain = vacation?.overTimeRemain ?? controller.remainingOT.value;
      final leaveUsed = controller.mode == TimeOffFormMode.create
          ? (vacation?.paidLeaveUsedTotal ??
                controller.paidLeaveUsedTotal.value)
          : (vacation?.paidLeaveUsedTotal ?? controller.pendingLeave.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Tên', name),
           SizedBox(height: 8.h),
          _buildInfoRow('Chức danh', position),
           SizedBox(height: 8.h),
          _buildInfoRow('Cơ quan/Đơn vị', department),
           SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow2('Tồn phép', '$leaveRemain'),
              _buildInfoRow2('Tồn OT', '$otRemain'),
              _buildInfoRow2('Phép đã nghỉ', '$leaveUsed'),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildInfoRow2(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: '$label:',
          fontSize: 13,
          color: TimeOffCreateColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(width: 8.w),
        TextWidget(
          text: value,
          fontSize: 13,
          color: TimeOffCreateColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130.w,
          child: TextWidget(
            text: '$label:',
            fontSize: 13,
            color: TimeOffCreateColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: TextWidget(
            text: value,
            fontSize: 13,
            color: TimeOffCreateColors.textPrimary,
            fontWeight: FontWeight.w600,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
