import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/action_button.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/screen/edit_appointment_summary_screen.dart';

class QuickActionButtons extends StatelessWidget {
  final String status;
  final AppointmentEntity appointment; 

  const QuickActionButtons({super.key,required this.appointment, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (status == 'pending') ...[
              Expanded(child: ActionButton(icon: CupertinoIcons.check_mark, label: "Confirm", onTap: () {})),
              const SizedBox(width: 12),
              Expanded(child: ActionButton(icon: CupertinoIcons.xmark, label: "Reject", onTap: () {}, isDestructive: true)),
            ],
            if (status == 'confirmed') ...[
              Expanded(child: ActionButton(icon: CupertinoIcons.video_camera_solid, label: "Start Call", onTap: () {})),
              const SizedBox(width: 12),
              Expanded(child: ActionButton(icon: CupertinoIcons.chat_bubble_2, label: "Open Chat", onTap: () {})),
            ],
            if (status == 'completed') ...[
              Expanded(child: ActionButton(icon: CupertinoIcons.doc_text, label: "View History", onTap: () {})),
               Expanded(
                child: ActionButton(
                  icon: CupertinoIcons.pencil_ellipsis_rectangle,
                  label: "Add/Edit Summary", // Label change kiya
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EditAppointmentSummaryScreen(
                        appointment: appointment, // Appointment object pass karein
                      ),
                    ));
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
