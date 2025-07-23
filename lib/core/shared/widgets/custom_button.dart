// lib/shared/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    // Get the current theme from the context
    final theme = Theme.of(context);

    // Common style for both button types
    final ButtonStyle baseStyle = ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(vertical: height != null ? 0 : 16.h),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      minimumSize: WidgetStateProperty.all<Size>(
        Size(width ?? double.infinity, height?.h ?? 50.h),
      ),
    );

    // The content of the button (either text or a loader)
    final Widget buttonChild = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.w,
            child: CircularProgressIndicator(
              // Use the button's foreground color for the loader
              // This will be white in filled buttons and primary in outlined buttons
              color: 
                  theme.colorScheme.onPrimary,
              strokeWidth: 2,
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          );

    // Return an OutlinedButton or ElevatedButton based on the 'isOutlined' flag
    return  ElevatedButton(
            style: baseStyle.copyWith(
              // Define specific styles for the elevated (filled) button
              backgroundColor:
                  WidgetStateProperty.all(theme.colorScheme.primary),
              foregroundColor:
                  WidgetStateProperty.all(theme.colorScheme.onPrimary),
            ),
            // Disable the button if it's loading or if onTap is null
            onPressed: isLoading ? null : onTap,
            child: buttonChild,
          );
  }
}