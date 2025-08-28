// lib/core/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool isReadOnly;
  final int maxLines;
  final int? maxLength;
  final bool isObscure;
  final Widget? suffixIcon;
  final IconData? prefixIcon; // <<< --- NAYI, OPTIONAL PROPERTY ---
  final String? labelText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.isObscure = false,
    this.suffixIcon,
    this.prefixIcon, // <<< --- CONSTRUCTOR MEIN ADD KIYA ---
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textStyle = GoogleFonts.inter(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w500,
    );
    
    final hintStyle = GoogleFonts.inter(
      color: colorScheme.onSurface.withOpacity(0.5),
    );

    return TextFormField(
      readOnly: isReadOnly,
      controller: controller,
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      obscureText: isObscure,
      style: textStyle.copyWith(fontSize: 14.sp),
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintStyle.copyWith(fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        filled: true,
        fillColor: colorScheme.surface,
        suffixIcon: suffixIcon,
        
        // <<< --- NAYA LOGIC YAHAN HAI ---
        // Agar prefixIcon diya gaya hai, to use dikhao.
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: colorScheme.onSurface.withOpacity(0.6), // Icon ko thoda aacha look dein
              )
            : null,
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          color: colorScheme.error,
        ),
      ),
    );
  }
}