import 'package:flutter/material.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class BannerPlaceholderWidget extends StatelessWidget {
  const BannerPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.28;

    return Container(
      height: bannerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
      ),
    );
  }
}
