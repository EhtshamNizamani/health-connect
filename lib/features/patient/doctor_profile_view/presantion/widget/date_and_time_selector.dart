import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_event.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_state.dart';
import 'package:intl/intl.dart';

class DateAndTimeSelector extends StatelessWidget {
  final String doctorId;
  const DateAndTimeSelector({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DateAndTimeSelectorBody(doctorId: doctorId);
  }
}

// I've separated the body into a StatefulWidget to manage the locally selected date
class _DateAndTimeSelectorBody extends StatefulWidget {
  final String doctorId;
  const _DateAndTimeSelectorBody({required this.doctorId});

  @override
  State<_DateAndTimeSelectorBody> createState() =>
      __DateAndTimeSelectorBodyState();
}

class __DateAndTimeSelectorBodyState extends State<_DateAndTimeSelectorBody> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. DATE PICKER SECTION ---
        Text(
          "Select Date",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DatePicker(
          height: 80.h,
          DateTime.now(),
          initialSelectedDate: _selectedDate,
          selectionColor: theme.colorScheme.primary,
          selectedTextColor: Colors.white,
          daysCount: 7,
          onDateChange: (date) {
            // When the user picks a new date:
            // 1. Update the local state to show the new date selection.
            setState(() {
              _selectedDate = date;
            });
            // 2. Tell the BLoC to clear the old time slot selection.
            context.read<DoctorProfileViewBloc>().add(
              const TimeSlotSelected(null),
            );
            // 3. Tell the BLoC to fetch available slots for this new date.
            context.read<DoctorProfileViewBloc>().add(
              FetchAvailableSlotsViewEvent(
                doctorId: widget.doctorId,
                date: date,
              ),
            );
          },
        ),

        const Divider(height: 48),

        // --- 2. TIME SLOT PICKER SECTION ---
        Text(
          "Available Time Slots",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          builder: (context, state) {
            // We only build the slots when the parent state is Loaded.
            if (state is DoctorProfileViewLoaded) {
              // Show a loader specifically for the slots area
              if (state.areSlotsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // Show an error if fetching slots failed
              if (state.slotsError != null) {
                return Center(
                  child: Text(
                    state.slotsError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }
              // Show a message if no slots are available
              if (state.availableSlots == null ||
                  state.availableSlots!.isEmpty) {
                return const Center(
                  child: Text("No available slots for this day."),
                );
              }

              // If we have slots, build the Wrap of ChoiceChips
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: state.availableSlots!.map((slot) {
                  // To check if a chip is selected, we look at the BLoC's state
                  final isSelected = state.selectedSlot == slot;

                  return ChoiceChip(
                    label: Text(DateFormat('hh:mm a').format(slot)),
                    selected: isSelected,
                    onSelected: (selected) {
                      // When a user taps a chip:
                      // Tell the BLoC to update its state with the new selection.
                      // If the user taps the selected chip again, 'selected' will be false,
                      // and we pass null to the BLoC to deselect it.
                      context.read<DoctorProfileViewBloc>().add(
                        TimeSlotSelected(selected ? slot : null),
                      );
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                  );
                }).toList(),
              );
            }
            // If the main profile isn't even loaded, show nothing here.
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
