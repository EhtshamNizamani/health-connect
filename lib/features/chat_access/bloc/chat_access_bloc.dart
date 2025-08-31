// chat_access_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/services/chat_access_service.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_appointments_between_usecase.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_event.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_state.dart';

class ChatAccessBloc extends Bloc<ChatAccessEvent, ChatAccessState> {
  // Purane use cases hata dein
  final GetAppointmentsBetweenUseCase _getAppointmentsBetweenUseCase;
  
  ChatAccessBloc(
    this._getAppointmentsBetweenUseCase,
  ) : super(ChatAccessInitial()) {
    // Sirf ek hi event handler rakhein
    on<CheckChatAccess>(_onCheckChatAccess);
  }
  
  Future<void> _onCheckChatAccess(
    CheckChatAccess event,
    Emitter<ChatAccessState> emit,
  ) async {
    emit(ChatAccessLoading());
    
    print("[ChatAccessBloc] 🔍 Checking access for Patient: ${event.patientId}, Doctor: ${event.doctorId}");
      
    // Naye, focused use case ko call karein
    final result = await _getAppointmentsBetweenUseCase(
      event.patientId, 
      event.doctorId,
    );
      
    result.fold(
      (failure) {
        print("[ChatAccessBloc] ❌ Failed to get appointments: ${failure.message}");
        emit(ChatAccessError(failure.message));
      },
      (relevantAppointments) {
        print("[ChatAccessBloc] 🎯 Found ${relevantAppointments.length} relevant appointments");
              
        final accessResult = ChatAccessService.canAccessChat(relevantAppointments);
              
        if (accessResult.canAccess) {
          final primaryAppointment = ChatAccessService.getRelevantAppointment(relevantAppointments);
          print("[ChatAccessBloc] ✅ Access granted");
          emit(ChatAccessAllowed(
            relevantAppointments: relevantAppointments,
            primaryAppointment: primaryAppointment,
          ));
        } else {
          print("[ChatAccessBloc] ❌ Access denied: ${accessResult.message}");
          emit(ChatAccessDenied(
            reason: accessResult.message,
            appointments: relevantAppointments,
          ));
        }
      },
    );
  }
}