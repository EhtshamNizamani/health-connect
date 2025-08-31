
import 'package:equatable/equatable.dart';

abstract class ChatAccessEvent extends Equatable {
  const ChatAccessEvent();
  @override
  List<Object> get props => [];
}

class CheckChatAccess extends ChatAccessEvent {
  final String patientId;
  final String doctorId;
  
  const CheckChatAccess({
    required this.patientId,
    required this.doctorId,
  });
  
  @override
  List<Object> get props => [patientId, doctorId];
}

class RefreshChatAccess extends ChatAccessEvent {
  final String patientId;
  final String doctorId;
  
  const RefreshChatAccess({
    required this.patientId,
    required this.doctorId,
  });
  
  @override
  List<Object> get props => [patientId, doctorId];
}
