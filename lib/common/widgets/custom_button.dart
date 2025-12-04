import 'package:flutter/material.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;
  final double? width;
  final double? height;
  final double? horizontalPadding;
  final double? verticalPadding;
  final int? fontSize;
  final Color? borderColor;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.isOutlined = false,
    this.width,
    this.height,
    this.horizontalPadding,
    this.verticalPadding,
    this.fontSize,
    this.borderColor = Colors.transparent,
    this.isLoading = false,
  }) : super(key: key);

  bool get isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : () => onPressed?.call(),
      child: Opacity(
        opacity: isDisabled
            ? 0.6
            : 1.0, 
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor ?? Colors.transparent),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? Colors.white,
                    ),
                  ),
                )
              : TextWidget(
                  text: text,
                  fontSize: fontSize?.toDouble() ?? 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.white,
                ),
        ),
      ),
    );
  }
}
