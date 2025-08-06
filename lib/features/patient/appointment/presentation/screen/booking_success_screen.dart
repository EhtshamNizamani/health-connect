// lib/features/appointment/presentation/screens/booking_success_screen.dart

import 'package:flutter/material.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 120,
              ),
              const SizedBox(height: 32),
              Text(
                "Appointment Confirmed!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Your appointment has been successfully booked. You can view the details in the 'My Appointments' section.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onTap: () {
                    // User ko wapas home/appointments screen par bhej do
                    // Pop karke home screen par jaate hain
                    Navigator.of(context).pop();
                  },
                 
                  text: "Done",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}