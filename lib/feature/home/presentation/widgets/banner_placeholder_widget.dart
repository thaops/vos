import 'package:flutter/material.dart';

class BannerPlaceholderWidget extends StatelessWidget {
  final double? height;

  const BannerPlaceholderWidget({super.key, this.height});

  const BannerPlaceholderWidget.withHeight({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = height ?? screenHeight * 0.28;

    return Container(
      height: bannerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 255, 255, 255),
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Image.asset('assets/images/icon_app.png', width: 56, height: 56),
      ),
    );
  }
}
