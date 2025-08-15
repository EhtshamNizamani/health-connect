
import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

abstract class ChatAccessState extends Equatable {
  const ChatAccessState();
  @override
  List<Object> get props => [];
}

class ChatAccessInitial extends ChatAccessState {}

class ChatAccessLoading extends ChatAccessState {}

class ChatAccessAllowed extends ChatAccessState {
  final List<AppointmentEntity> relevantAppointments;
  final AppointmentEntity? primaryAppointment;
  
  const ChatAccessAllowed({
    required this.relevantAppointments,
    this.primaryAppointment,
  });
  
  @override
  List<Object> get props => [relevantAppointments, primaryAppointment ?? ''];
}

class ChatAccessDenied extends ChatAccessState {
  final String reason;
  final List<AppointmentEntity> appointments;
  
  const ChatAccessDenied({
    required this.reason,
    required this.appointments,
  });
  
  @override
  List<Object> get props => [reason, appointments];
}

class ChatAccessError extends ChatAccessState {
  final String message;
  
  const ChatAccessError(this.message);
  
  @override
  List<Object> get props => [message];
}
