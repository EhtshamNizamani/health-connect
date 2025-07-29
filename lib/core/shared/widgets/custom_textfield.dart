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
  final bool isObscure; // Added for password fields
  final Widget? suffixIcon; // Added for things like password visibility toggle
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
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define a base text style using GoogleFonts and merge it with theme styles
    final textStyle = GoogleFonts.inter(
      // Use the theme's default text color
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w500,
    );
    
    final hintStyle = GoogleFonts.inter(
      // Use a less prominent color for hints
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
      cursorColor: colorScheme.primary, // Use theme's primary color
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintStyle.copyWith(fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        filled: true,
        // The background of the text field should be the card/surface color
        fillColor: colorScheme.surface,
        suffixIcon: suffixIcon,
        
        // Define a common border style to avoid repetition
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r), // A slightly larger radius looks more modern
          // Use the theme's outline color for the border
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          // Use the primary color for the border when focused
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          // Use the error color for the border on validation error
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