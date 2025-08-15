import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/info_row.dart';

class PatientSnapshotCard extends StatelessWidget {
  final UserEntity patient;
  const PatientSnapshotCard({super.key, required this.patient});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
       child: Column(
          children: [
            InfoRowWithIcon(
              title: "Allergies",
              value:  "None Reported",
            ),
            InfoRowWithIcon(
              title: "Chronic Condition",
              value:  "None Reported",
            ),
            const Divider(height: 24),
            InfoRowWithIcon(
              title: "Last Visit Note",
              value:
                  "Prescribed Ventolin inhaler. Condition stable. Follow up in 2 weeks.",
            ),
          ],
        ),
      ),
    );
  }
}
