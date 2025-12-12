import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_info_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_button.dart';

class GoogleUserContent extends StatelessWidget {
  final ProfileController controller;

  const GoogleUserContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final googleUser = controller.googleUser.value;
    
    // Null safety check
    if (googleUser == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              GoogleUserHeaderCard(user: googleUser, controller: controller),
              SizedBox(height: 24.h),
              LinkViagsButton(controller: controller),
              SizedBox(height: 24.h),
              GoogleUserInfoCard(user: googleUser, controller: controller),
            ],
          ),
          SizedBox(height: 24.h),
          
        ],
      ),
    );
  }
}
