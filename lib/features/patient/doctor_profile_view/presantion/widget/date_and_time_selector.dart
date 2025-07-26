import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_state.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_event.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_state.dart';
import 'package:intl/intl.dart';
// TODO: We will create and import the BLoC for slots later

class DateAndTimeSelector extends StatefulWidget {
  final String doctorId;
  const DateAndTimeSelector({super.key, required this.doctorId});

  @override
  State<DateAndTimeSelector> createState() => _DateAndTimeSelectorState();
}

class _DateAndTimeSelectorState extends State<DateAndTimeSelector> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- DATE PICKER ---
        Text("Select Date", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DatePicker(
          height: 80.h,
          DateTime.now(),
          initialSelectedDate: _selectedDate,
          selectionColor: theme.colorScheme.primary,
          selectedTextColor: Colors.white,
          daysCount: 7,
          onDateChange: (date) {
            setState(() {
              _selectedDate = date;
              _selectedTimeSlot = null;
            });
            // THE FIX: Fire the correct event to fetch only the slots
            context.read<DoctorProfileViewBloc>().add(
              FetchAvailableSlotsViewEvent(doctorId: widget.doctorId, date: date),
            );
          },
        ),

        const Divider(height: 48),

        // --- TIME SLOT PICKER ---
        Text("Available Time Slots", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          buildWhen: (prev, current) {
            if (prev is! DoctorProfileViewLoaded || current is! DoctorProfileViewLoaded) {
              return true;
            }
            return current.availableSlots != prev.availableSlots || 
                   current.areSlotsLoading != prev.areSlotsLoading ||
                   current.slotsError != prev.slotsError;
          },
          builder: (context, state) {
            // We only care about the DoctorProfileViewLoaded state for slots
            if (state is DoctorProfileViewLoaded) {
              if (state.areSlotsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.slotsError != null) {
                return Center(child: Text(state.slotsError!, style: TextStyle(color: theme.colorScheme.error)));
              }
              if (state.availableSlots == null || state.availableSlots!.isEmpty) {
                return const Center(child: Text("No available slots for this day."));
              }
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: state.availableSlots!.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(DateFormat('hh:mm a').format(slot)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() { _selectedTimeSlot = selected ? slot : null; });
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                      ),
                    ),
                  );
                }).toList(),
              );
            }
            // If the parent state is something else (like Loading or Initial), show an empty box
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}