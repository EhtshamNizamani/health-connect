// lib/features/appointment/presentation/screens/payment_summary_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart'; // Apne service locator ka import
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_bloc.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_event.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_state.dart';
import 'package:health_connect/features/patient/appointment/presentation/screen/booking_success_screen.dart';
import 'package:intl/intl.dart';

class PaymentSummaryScreen extends StatelessWidget {
  final AppointmentEntity appointmentDetails;

  const PaymentSummaryScreen({super.key, required this.appointmentDetails});

  @override
  Widget build(BuildContext context) {
    // Yahan par BookingBloc ko provide karein
    return BlocProvider(
      create: (context) => sl<BookingBloc>(), // Service locator se BLoC lein
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Confirm & Pay"),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            // State changes ko sunein
            if (state is BookingSuccess) {
              // Payment aur booking successful hone par, success screen par navigate karein
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
                (route) => route.isFirst, // Peeche ki saari screens hata dein
              );
            }
            if (state is BookingFailure) {
              // Failure par error dikhayein
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            // Loading state ke liye UI
            final isLoading = state is BookingLoading;

            return AbsorbPointer(
              absorbing: isLoading,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Details Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. ${appointmentDetails.doctorName}",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              title: "Date & Time",
                              value: DateFormat('EEE, MMM d, yyyy • hh:mm a').format(appointmentDetails.appointmentDateTime),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              icon: Icons.person,
                              title: "Patient Name",
                              value: appointmentDetails.patientName,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Fee Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Consultation Fee", style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              "₹${appointmentDetails.consultationFee}",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        
                        onPressed: isLoading ? null : () {
                          // Payment process shuru karne ke liye event bhejein
                          context.read<BookingBloc>().add(
                            PaymentAndBookingStarted(appointmentDetails),
                          );
                        },
                        icon: isLoading ? const SizedBox.shrink() : const Icon(Icons.security),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text("Pay ₹${appointmentDetails.consultationFee} Securely"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }
}