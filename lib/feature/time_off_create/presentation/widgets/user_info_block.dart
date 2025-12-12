import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/controller/time_off_create_controller.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class UserInfoBlock extends GetView<TimeOffCreateController> {
  const UserInfoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() {
        final vacation = controller.personalVacation.value;
        final isLoading = controller.status == ControllerStatus.loading;

        if (isLoading && vacation == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (vacation == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                'Tên',
                controller.userName.value.isEmpty
                    ? '-'
                    : controller.userName.value,
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                'Chức danh',
                controller.userPosition.value.isEmpty
                    ? '-'
                    : controller.userPosition.value,
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                'Đơn vị',
                controller.userDepartment.value.isEmpty
                    ? '-'
                    : controller.userDepartment.value,
              ),
              const SizedBox(height: 6),
              _buildInfoRow('Tồn phép', '${controller.remainingLeave.value}'),
              const SizedBox(height: 6),
              _buildInfoRow('Tồn OT', '${controller.remainingOT.value}'),
              const SizedBox(height: 6),
              _buildInfoRow(
                'Phép đã nghỉ',
                '${controller.paidLeaveUsedTotal.value}',
              ),
            ],
          );
        }

        // Có data từ API -> hiển thị
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên', vacation.fullName),
            const SizedBox(height: 6),
            _buildInfoRow('Chức danh', vacation.jobTitleNameVN),
            const SizedBox(height: 6),
            _buildInfoRow('Đơn vị', vacation.departmentName),
            const SizedBox(height: 6),
            _buildInfoRow('Tồn phép', '${vacation.paidLeaveRemain}'),
            const SizedBox(height: 6),
            _buildInfoRow('Tồn OT', '${vacation.overTimeRemain}'),
            const SizedBox(height: 6),
            _buildInfoRow('Phép đã nghỉ', '${vacation.paidLeaveUsedTotal}'),
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
          width: 200,
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
