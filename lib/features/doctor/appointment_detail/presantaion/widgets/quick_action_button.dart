import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/utils/create_chat_room_id.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_bloc.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_event.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/action_button.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/screen/edit_appointment_summary_screen.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/screens/patient_details_screen.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_event.dart';

class QuickActionButtons extends StatelessWidget {
  final String status;
  final AppointmentEntity appointment;
  final UserEntity patient;

  const QuickActionButtons({
    super.key,
    required this.appointment,
    required this.patient,
    required this.status,
  });

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
          children: _buildButtons(context),
        ),
      ),
    );
  }

  /// Decides which list of buttons to show based on the appointment status.
  List<Widget> _buildButtons(BuildContext context) {
    switch (status) {
      case 'pending':
        return _buildPendingActions(context);
      case 'confirmed':
        return _buildConfirmedActions(context);
      case 'completed':
        return _buildCompletedActions(context);
      default:
        return []; // No actions for other statuses like 'cancelled' or 'no-show'
    }
  }

  /// Builds the "Confirm" and "Reject" buttons for 'pending' status.
  List<Widget> _buildPendingActions(BuildContext context) {
    return [
      Expanded(
        child: ActionButton(
          icon: CupertinoIcons.check_mark,
          label: "Confirm",
          onTap: () => context.read<DoctorAppointmentsBloc>().add(
                ConfirmAppointment(appointment.id),
              ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ActionButton(
          icon: CupertinoIcons.xmark,
          label: "Reject",
          onTap: () => context.read<DoctorAppointmentsBloc>().add(
                CancelAppointment(appointment.id),
              ),
          isDestructive: true,
        ),
      ),
    ];
  }

  /// Builds the "Start Call" and "Open Chat" buttons for 'confirmed' status.
  List<Widget> _buildConfirmedActions(BuildContext context) {
    return [
      Expanded(
        child: ActionButton(
          icon: CupertinoIcons.video_camera_solid,
          label: "Start Call",
          onTap: () => _onStartCall(context),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ActionButton(
          icon: CupertinoIcons.chat_bubble_2,
          label: "Open Chat",
          onTap: () => _onOpenChat(context),
        ),
      ),
    ];
  }

  /// Builds the "View History" and "Add/Edit Summary" buttons for 'completed' status.
  List<Widget> _buildCompletedActions(BuildContext context) {
    return [
      Expanded(
        child: ActionButton(
          icon: CupertinoIcons.doc_text,
          label: "View History",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailScreen(patientId: patient.id),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ActionButton(
          icon: CupertinoIcons.pencil_ellipsis_rectangle,
          label: "Add/Edit Summary",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EditAppointmentSummaryScreen(appointment: appointment),
            ),
          ),
        ),
      ),
    ];
  }

  // --- LOGIC HELPERS ---

  /// Gathers all necessary data and dispatches the [StartCall] event.
  void _onStartCall(BuildContext context) {
    final currentUser = context.read<AuthBloc>().state.user;
    if (currentUser == null || currentUser.role != 'doctor') return;

    final chatRoomId = createChatRoomId(currentUser.id, patient.id);
    final doctorEntity = _createDoctorEntity(currentUser);

    context.read<VideoCallBloc>().add(
          StartCall(
            callId: chatRoomId,
            receiverId: patient.id,
            currentUser: currentUser,
            doctor: doctorEntity,
            patient: patient,
          ),
        );
  }

  /// Gathers all necessary data and navigates to the [ChatRoomScreen].
  void _onOpenChat(BuildContext context) {
    final currentUser = context.read<AuthBloc>().state.user;
    if (currentUser == null) return;

    final chatRoomId = createChatRoomId(currentUser.id, patient.id);
    final doctorEntity = _createDoctorEntity(currentUser);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatRoomId: chatRoomId,
          chatPartnerName: patient.name,
          receiverId: patient.id,
          doctor: doctorEntity,
          patient: patient,
        ),
      ),
    );
  }

  /// Creates a [DoctorEntity] from a [UserEntity] to pass to other screens.
  DoctorEntity _createDoctorEntity(UserEntity currentUser) {
    // This is a placeholder conversion. A better approach would be a factory
    // constructor or having the full DoctorEntity in the AuthBloc state.
    return DoctorEntity(
      uid: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      photoUrl: currentUser.photoUrl ?? '',
      specialization: '',
      bio: '',
      experience: 0,
      clinicAddress: '',
      consultationFee: 0,
      weeklyAvailability: {},
    );
  }
}