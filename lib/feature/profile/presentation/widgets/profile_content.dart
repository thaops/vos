import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_button.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/personal_info_detail_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/unlink_viags_button.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/viags_connection_status_card.dart';
import 'package:vos_flutter/router/app_router.dart';

class ProfileContent extends StatelessWidget {
  final ProfileController controller;

  const ProfileContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.userProfile.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeaderCard(user: user, controller: controller),
          SizedBox(height: 16.h),

          Obx(() {
            if (controller.isViagsLinked.value) {
              return Column(
                children: [
                  ViagsConnectionStatusCard(),
                  SizedBox(height: 16.h),

                  PersonalInfoDetailCard(user: user),

                  SizedBox(height: 16.h),
                  UnlinkViagsButton(controller: controller),
                ],
              );
            } else {
              return Column(
                children: [
                  LinkViagsButton(controller: controller),
                  SizedBox(height: 24.h),
                ],
              );
            }
          }),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildVacationInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
