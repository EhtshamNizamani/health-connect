import 'package:flutter/material.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';
import 'package:health_connect/core/data/entities/time_slot_entity.dart';
import 'package:intl/intl.dart'; // For formatting time

class DayAvailabilityCard extends StatelessWidget {
  final String day;
  final DailyAvailability availability;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddTimeSlot;
  final ValueChanged<TimeSlot> onRemoveTimeSlot;

  const DayAvailabilityCard({
    super.key,
    required this.day,
    required this.availability,
    required this.onToggle,
    required this.onAddTimeSlot,
    required this.onRemoveTimeSlot,
  });

  // Helper to format 24-hour time to AM/PM for display
  String _formatTime(String time) {
    final format24 = DateFormat("HH:mm");
    final format12 = DateFormat("hh:mm a");
    return format12.format(format24.parse(time));
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Day and Toggle Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Capitalize the first letter of the day
                  day.substring(0, 1).toUpperCase() + day.substring(1),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: availability.isWorking,
                  onChanged: onToggle,
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
            
            if (availability.isWorking) ...[
              const Divider(height: 24),
              // List of Time Slots for this day
              ...availability.slots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}",
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => onRemoveTimeSlot(slot),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              // Add Time Slot Button
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onAddTimeSlot,
                icon: const Icon(Icons.add),
                label: const Text("Add Time Slot"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ] else ... [
               const SizedBox(height: 16),
               Text("Day Off", style: TextStyle(color: theme.colorScheme.outline)),
            ]
          ],
        ),
      ),
    );
  }
}