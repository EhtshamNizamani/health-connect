// lib/shared/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/custom_text_widget.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isBorder;
  final Color? buttonColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double fontSize;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isBorder = false,
    this.buttonColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height?.h ?? 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.grey
              : isBorder
                  ? Colors.transparent
                  : buttonColor ?? AppColors.primary,
          border: isBorder
              ? Border.all(color: buttonColor ?? AppColors.primary)
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : CustomTextWidget(
                text: text,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor ?? 
                    (isBorder
                        ? AppColors.primary
                        : AppColors.white),
              ),
      ),
    );
  }
}
