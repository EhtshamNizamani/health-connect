import 'package:flutter/material.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart'; // Apna CustomButton import karein

class BookAppointmentButton extends StatelessWidget {
  final VoidCallback onTap;

  const BookAppointmentButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // We wrap it in a SafeArea and Padding to ensure it looks good on all devices
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: "Book Appointment",
          onTap: onTap,
        ),
      ),
    );
  }
}