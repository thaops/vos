import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/design_system/tokens/app_sizes.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double? heightAppBar;
  final bool? isTrueBack;
  final IconData? iconRightfirst;
  final IconData? iconRightSecond;
  final Color? colorfirst;
  final Color? colorSecond;
  final bool? isBack;
  final SizedBox? sizeBox;

  final bool? isTitleCenter;
  final Function()? functionfirst;
  final Function()? functionSecond;

  final IconData? iconRightthird;
  final Color? colorThird;
  final Function()? functionThird;

  final Color? backgroundColor;

  final String? image;

  final Widget? badgeIcon;

  const AppBarWidget({
    super.key,
    this.title,
    this.heightAppBar = 45,
    this.isTrueBack,
    this.iconRightfirst,
    this.iconRightSecond,
    this.colorfirst,
    this.colorSecond,
    this.functionfirst,
    this.functionSecond,
    this.iconRightthird,
    this.colorThird,
    this.functionThird,
    this.isBack = true,
    this.backgroundColor,
    this.sizeBox,
    this.image,
    this.isTitleCenter = true,
    this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive icon size cho mobile - nhỏ hơn khi landscape
    final iconSize = isLandscape ? AppSizes.iconXSmall : AppSizes.iconMedium;

    // Responsive font size cho mobile - nhỏ hơn khi landscape
    final titleFontSize = isLandscape ? 12.0 : 16.0;

    // Responsive image width
    final imageWidth = isLandscape
        ? (screenWidth * 0.12).clamp(50.0, 80.0)
        : (screenWidth * 0.25).clamp(80.0, 120.0);

    // Responsive button constraints - nhỏ hơn khi landscape
    final buttonConstraints = isLandscape
        ? const BoxConstraints(minWidth: 32, minHeight: 32)
        : const BoxConstraints(minWidth: 40, minHeight: 40);

    // Responsive leading width - nhỏ hơn khi landscape
    final leadingWidth = isLandscape ? 40.0 : 48.0;

    // Responsive title spacing - nhỏ hơn khi landscape
    final titleSpacing = isLandscape ? 4.0 : 8.0;

    return AppBar(
      toolbarHeight: isLandscape ? 48.0 : (heightAppBar ?? kToolbarHeight),
      backgroundColor: backgroundColor ?? AppColors.primary,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: isBack != false,
      leading: isBack == false
          ? (sizeBox ?? const SizedBox(width: 0))
          : IconButton(
              onPressed: () {
                Get.back(result: isTrueBack ?? false);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.white,
                size: iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      leadingWidth: isBack == false ? 0 : leadingWidth,
      centerTitle: isTitleCenter,
      title: title == null
          ? image != null
                ? Image.asset(image!, fit: BoxFit.contain, width: imageWidth)
                : const SizedBox()
          : TextWidget(
              text: title!,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              maxLines: 1,
            ),
      titleSpacing: titleSpacing,
      actions: [
        if (badgeIcon != null) badgeIcon!,
        if (iconRightthird != null)
          IconButton(
            onPressed: functionThird,
            icon: Icon(
              iconRightthird,
              color: colorThird ?? AppColors.white,
              size: iconSize,
            ),
            padding: EdgeInsets.zero,
            constraints: buttonConstraints,
          ),
        if (iconRightSecond != null)
          IconButton(
            onPressed: functionSecond,
            icon: Icon(
              iconRightSecond,
              color: colorSecond ?? AppColors.white,
              size: iconSize,
            ),
            padding: EdgeInsets.zero,
            constraints: buttonConstraints,
          ),
        if (iconRightfirst != null)
          IconButton(
            onPressed: functionfirst,
            icon: Icon(
              iconRightfirst,
              color: colorfirst ?? AppColors.white,
              size: iconSize,
            ),
            padding: EdgeInsets.zero,
            constraints: buttonConstraints,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(heightAppBar ?? kToolbarHeight);
}
