// lib/shared/widgets/custom_text_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_connect/core/constants/app_color.dart';

class CustomTextButton extends StatelessWidget {
  final String buttonName;
  final Color? textColor;
  final VoidCallback? onPressed;
  final double fontSize;

  const CustomTextButton({
    super.key,
    required this.buttonName,
    this.onPressed,
    this.fontSize = 12,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.all(4.w)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: GoogleFonts.inter(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.primary,
        ),
      ),
    );
  }
}
