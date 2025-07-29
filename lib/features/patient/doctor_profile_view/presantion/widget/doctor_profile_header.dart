import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorProfileHeader extends StatelessWidget {
  final DoctorEntity doctor;
  final String patientId; // Now required

  const DoctorProfileHeader({
    super.key,
    required this.doctor,
    required this.patientId,
  });

  // Helper function to create a consistent chat room ID
  String _createChatRoomId(String doctorId, String patientId) {
    // Sort the UIDs alphabetically to ensure the ID is the same regardless of who starts the chat
    if (doctorId.compareTo(patientId) > 0) {
      return '${doctorId}_$patientId';
    } else {
      return '${patientId}_$doctorId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
 return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
      children: [
        // --- Top Section: Photo, Name, Specialization, Chat Button ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo
             CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: doctor.photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(doctor.photoUrl)
                  : null,
              child: doctor.photoUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialization,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- THE CHAT BUTTON ---
            if (patientId.isNotEmpty)
              GestureDetector(
                // <<<--- THE FIX IS INSIDE THIS onTap ---
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  
                  // Make sure the current user is a patient before proceeding
                  if (authState is AuthenticatedPatient) {
                    final patient = authState.user;
                    final chatRoomId = _createChatRoomId(doctor.uid, patient.id);
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          chatRoomId: chatRoomId,
                          chatPartnerName: doctor.name,
                          receiverId: doctor.uid,
                          // Pass the full, real entities
                          patient: patient,
                          doctor: doctor, 
                        ),
                      ),
                    );
                  } else {
                    // This can happen if a doctor is somehow viewing another doctor's profile
                    // Show a message or do nothing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You must be logged in as a patient to start a chat.")),
                    );
                  }
                },
                // <<<--- END OF FIX ---
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        
        // --- Rating and Experience Section ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Average Rating
            if (doctor.reviewCount > 0)
              Column(
                children: [
                  Text(
                    doctor.averageRating.toStringAsFixed(1),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Rating", style: theme.textTheme.bodyMedium),
                ],
              ),
            // Experience
            Column(
              children: [
                Text(
                  '${doctor.experience}+',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("Years Exp.", style: theme.textTheme.bodyMedium),
              ],
            ),
            // Review Count
            Column(
              children: [
                Text(
                  doctor.reviewCount.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("Reviews", style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ],
    );
  }
}