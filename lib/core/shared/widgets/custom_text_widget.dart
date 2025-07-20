// lib/shared/widgets/custom_text_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_connect/core/constants/app_color.dart';

class CustomTextWidget extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool? isUnderline;
  final int? maxLines;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final TextOverflow textOverflow;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.isUnderline,
    this.maxLines,
    this.letterSpacing,
    this.textAlign,
    this.textOverflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: maxLines ?? 2,
      overflow: textOverflow,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: fontSize?.sp ?? 14.sp,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? AppColors.text,
        letterSpacing: letterSpacing ?? 0.25,
        decoration:
            isUnderline == true ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}
