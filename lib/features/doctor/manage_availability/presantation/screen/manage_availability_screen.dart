import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/data/entities/time_slot_entity.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/bloc/manage_availability_bloc.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/bloc/manage_availability_event.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/bloc/manage_availability_state.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/widgets/day_availability_card.dart';

class ManageAvailabilityScreen extends StatelessWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return BlocProvider(
      create: (context) =>
          sl<ManageAvailabilityBloc>()..add(LoadInitialSchedule()),
      child: BlocConsumer<ManageAvailabilityBloc, ManageAvailabilityState>(
        listener: (context, state) {
          if (state is ManageAvailabilitySaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Schedule updated successfully!"),
                backgroundColor: AppColors.primary,
              ),
            );
            // Optionally, navigate back after saving
            // Navigator.of(context).pop();
          }
          if (state is ManageAvailabilityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: ${state.message}"),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<ManageAvailabilityBloc>();

          return Scaffold(
            appBar: AppBar(title: const Text("Manage Weekly Availability")),
            body: state is ManageAvailabilityLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: daysOfWeek.length,
                    itemBuilder: (context, index) {
                      final day = daysOfWeek[index];
                      // Get the schedule for the specific day from the BLoC state
                      final dailyAvailability = state.schedule[day];

                      if (dailyAvailability == null) {
                        // Show a loader for individual items if schedule is not fully loaded yet
                        return const Card(child: SizedBox(height: 100));
                      }

                      return DayAvailabilityCard(
                        day: day,
                        availability: dailyAvailability,
                        onToggle: (isWorking) {
                          bloc.add(DayToggled(day: day, isWorking: isWorking));
                        },
                        onAddTimeSlot: () async {
                          await _showAddTimeSlotDialog(context, day, bloc);
                        },
                        onRemoveTimeSlot: (slot) {
                          bloc.add(
                            TimeSlotRemoved(day: day, slotToRemove: slot),
                          );
                        },
                      );
                    },
                  ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: state is ManageAvailabilitySaving
                      ? null // Disable button while saving
                      : () => bloc.add(ScheduleSaved()),
                  child: state is ManageAvailabilitySaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Schedule"),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to show time pickers and add a new slot
  Future<void> _showAddTimeSlotDialog(
    BuildContext context,
    String day,
    ManageAvailabilityBloc bloc,
  ) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Start Time',
    );
    if (startTime == null) return; // User cancelled

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select End Time',
    );
    if (endTime == null) return; // User cancelled

    // Convert TimeOfDay to "HH:mm" format
    final String start =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    final String end =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";

    // Add the event to the BLoC
    bloc.add(
      TimeSlotAdded(
        day: day,
        newSlot: TimeSlot(startTime: start, endTime: end),
      ),
    );
  }
}
