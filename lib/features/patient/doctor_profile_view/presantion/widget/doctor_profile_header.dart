import 'package:flutter/material.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorProfileHeader extends StatelessWidget {
  final DoctorEntity doctor;

  const DoctorProfileHeader({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Profile Photo
        doctor.photoUrl.isNotEmpty
            ? CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.secondaryContainer,
                // Use CachedNetworkImageProvider for the background image
                backgroundImage: CachedNetworkImageProvider(doctor.photoUrl),
              )
            : CircleAvatar(
                // Fallback for when there is no photo
                radius: 50,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
        const SizedBox(height: 16),
        // Doctor's Name
        Text(
          doctor.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Specialization and Experience
        Text(
          "${doctor.specialization} • ${doctor.experience} years of experience",
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        // Dummy Rating and Reviews
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text("4.8 (124 reviews)", style: theme.textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}
