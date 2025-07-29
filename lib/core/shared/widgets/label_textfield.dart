import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_textfield.dart'; // Import your existing CustomTextField

class LabeledTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isObscure;
  final int maxLines;
  final Widget? suffixIcon;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.isObscure = false,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The Label Text
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 8.h),
        // The Text Field
        CustomTextField(
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          validator: validator,
          isObscure: isObscure,
          maxLines: maxLines,
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }
}