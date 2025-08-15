
import 'package:equatable/equatable.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_bloc.dart';

abstract class ChatAccessEvent extends Equatable {
  const ChatAccessEvent();
  @override
  List<Object> get props => [];
}

class CheckChatAccess extends ChatAccessEvent {
  final String patientId;
  final String doctorId;
  final UserType currentUserType; // Add this to identify who is checking
  
  const CheckChatAccess({
    required this.patientId,
    required this.doctorId,
    required this.currentUserType,
  });
  
  @override
  List<Object> get props => [patientId, doctorId, currentUserType];
}

class RefreshChatAccess extends ChatAccessEvent {
  final String patientId;
  final String doctorId;
  final UserType currentUserType;
  
  const RefreshChatAccess({
    required this.patientId,
    required this.doctorId,
    required this.currentUserType,
  });
  
  @override
  List<Object> get props => [patientId, doctorId, currentUserType];
}
