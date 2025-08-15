import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/core/services/chat_access_service.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_bloc.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_event.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_bloc.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_state.dart';

class DoctorProfileHeader extends StatelessWidget {
  final DoctorEntity doctor;
  final String patientId;

  const DoctorProfileHeader({
    super.key,
    required this.doctor,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DoctorBasicInfoRow(doctor: doctor, patientId: patientId),
        const SizedBox(height: 24),
        _DoctorStatsRow(doctor: doctor),
      ],
    );
  }
}

// --- Helper Widget #1: Doctor's Photo, Name, Specialization, and Chat Button ---
class _DoctorBasicInfoRow extends StatelessWidget {
  final DoctorEntity doctor;
  final String patientId;

  const _DoctorBasicInfoRow({required this.doctor, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
        // Name and Specialization
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
        // Chat Button logic is now in its own dedicated widget
        _ConditionalChatButton(doctor: doctor, patientId: patientId),
      ],
    );
  }
}

// --- Helper Widget #2: The Chat Button with all its BLoC logic ---
class _ConditionalChatButton extends StatelessWidget {
  final DoctorEntity doctor;
  final String patientId;

  const _ConditionalChatButton({required this.doctor, required this.patientId});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (patientId.isEmpty) {
      // Show a disabled chat icon if the user is not a logged-in patient
      return _buildDisabledChatButton(theme);
    }
    
    // Use BlocBuilder to get appointment data and decide whether to show the chat icon
    return BlocBuilder<PatientAppointmentsBloc, PatientAppointmentsState>(
      builder: (context, appointmentsState) {
        if (appointmentsState is PatientAppointmentsLoaded) {
          final allAppointments = [...appointmentsState.upcoming, ...appointmentsState.past];
          final doctorAppointments = allAppointments
              .where((appointment) => appointment.doctorId == doctor.uid)
              .toList();
          
          final shouldShowIcon = ChatAccessService.shouldShowChatIcon(doctorAppointments);

          if (shouldShowIcon) {
            return _buildEnabledChatButton(context, theme, doctorAppointments);
          } else {
            // If chat is not allowed, show nothing or a disabled button
            return const SizedBox.shrink(); 
          }
        }

        if (appointmentsState is PatientAppointmentsLoading) {
          return _buildLoadingIndicator(theme);
        }

        if (appointmentsState is PatientAppointmentsError) {
          // In case of error, you might want to allow chat as a fallback
          // or show a disabled icon. Let's show the button.
          return _buildEnabledChatButton(context, theme, []);
        }

        // For initial or other states, show nothing.
        return const SizedBox.shrink();
      },
    );
  }

  // --- UI building methods for the chat button ---
  Widget _buildDisabledChatButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Icon(Icons.chat_bubble_outline_rounded, size: 26, color: Colors.grey.shade400),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 26,
        width: 26,
        child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildEnabledChatButton(BuildContext context, ThemeData theme, List<AppointmentEntity> doctorAppointments) {
    return GestureDetector(
      onTap: () {
        final accessResult = ChatAccessService.canAccessChat(doctorAppointments);
        if (accessResult.canAccess) {
          _navigateToChat(context);
        } else {
          _showChatAccessDialog(context, accessResult.message);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Icon(Icons.chat_bubble_outline_rounded, size: 26, color: theme.colorScheme.primary),
      ),
    );
  }
  
  // --- Navigation and Dialog Logic ---
  String _createChatRoomId(String doctorId, String patientId) {
    return doctorId.compareTo(patientId) > 0 ? '${doctorId}_$patientId' : '${patientId}_$doctorId';
  }

  void _navigateToChat(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedPatient) {
      final patient = authState.user;
      final chatRoomId = _createChatRoomId(doctor.uid, patient.id);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<ChatAccessBloc>()
              ..add(CheckChatAccess(
                patientId: patient.id,
                doctorId: doctor.uid,
                currentUserType: UserType.patient,
              )),
            child: ChatRoomScreen(
              chatRoomId: chatRoomId,
              chatPartnerName: doctor.name,
              receiverId: doctor.uid,
              patient: patient,
              doctor: doctor,
            ),
          ),
        ),
      );
    }
  }

  void _showChatAccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Access Denied'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}

// --- Helper Widget #3: Rating, Experience, and Review Count ---
class _DoctorStatsRow extends StatelessWidget {
  final DoctorEntity doctor;
  const _DoctorStatsRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (doctor.reviewCount > 0)
          _StatItem(
            value: doctor.averageRating.toStringAsFixed(1),
            label: "Rating",
            theme: theme,
          ),
        _StatItem(
          value: '${doctor.experience}+',
          label: "Years Exp.",
          theme: theme,
        ),
        _StatItem(
          value: doctor.reviewCount.toString(),
          label: "Reviews",
          theme: theme,
        ),
      ],
    );
  }
}

// --- Helper Widget #4: A single stat item for the row above ---
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _StatItem({required this.value, required this.label, required this.theme});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
