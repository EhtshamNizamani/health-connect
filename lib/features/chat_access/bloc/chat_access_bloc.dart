// chat_access_bloc.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/services/chat_access_service.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_patient_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_event.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_state.dart';

// Enum to identify user type
enum UserType { patient, doctor }

class ChatAccessBloc extends Bloc<ChatAccessEvent, ChatAccessState> {
  final GetPatientAppointmentsUseCase _getPatientAppointmentsUseCase;
  final GetDoctorAppointmentsUseCase _getDoctorAppointmentsUseCase;
  // final GetCurrentUserUseCase _getCurrentUserUseCase;
  
  ChatAccessBloc(
    this._getPatientAppointmentsUseCase,
    this._getDoctorAppointmentsUseCase,
    // this._getCurrentUserUseCase,
  ) : super(ChatAccessInitial()) {
    on<CheckChatAccess>(_onCheckChatAccess);
    on<RefreshChatAccess>(_onRefreshChatAccess);
  }
  
  Future<void> _onCheckChatAccess(
    CheckChatAccess event,
    Emitter<ChatAccessState> emit,
  ) async {
    emit(ChatAccessLoading());
    await _checkAccess(
      event.patientId, 
      event.doctorId, 
      event.currentUserType,
      emit,
    );
  }
  
  Future<void> _onRefreshChatAccess(
    RefreshChatAccess event,
    Emitter<ChatAccessState> emit,
  ) async {
    await _checkAccess(
      event.patientId, 
      event.doctorId, 
      event.currentUserType,
      emit,
    );
  }
  
  Future<void> _checkAccess(
    String patientId,
    String doctorId,
    UserType currentUserType,
    Emitter<ChatAccessState> emit,
  ) async {
    try {
      print("[ChatAccessBloc] 🔍 Checking access for ${currentUserType.name} - Patient: $patientId, Doctor: $doctorId");
      
      // Choose the appropriate use case based on current user type
      Stream<Either<Failure, List<AppointmentEntity>>> appointmentsStream;
      
      if (currentUserType == UserType.patient) {
        appointmentsStream = _getPatientAppointmentsUseCase(patientId);
      } else {
        appointmentsStream = _getDoctorAppointmentsUseCase(doctorId);
      }
      
      // Listen to appointments stream
      await emit.forEach(
        appointmentsStream,
        onData: (result) {
          return result.fold(
            (failure) {
              print("[ChatAccessBloc] ❌ Failed to get appointments: ${failure.message}");
              return ChatAccessError(failure.message);
            },
            (appointments) {
              print("[ChatAccessBloc] 📊 Got ${appointments.length} appointments");
              
              // Filter appointments for the specific doctor-patient pair
              List<AppointmentEntity> relevantAppointments;
              
              if (currentUserType == UserType.patient) {
                // Patient view: filter by doctor
                relevantAppointments = appointments
                    .where((appointment) => appointment.doctorId == doctorId)
                    .toList();
              } else {
                // Doctor view: filter by patient  
                relevantAppointments = appointments
                    .where((appointment) => appointment.patientId == patientId)
                    .toList();
              }
              
              print("[ChatAccessBloc] 🎯 Found ${relevantAppointments.length} relevant appointments");
              
              final accessResult = ChatAccessService.canAccessChat(relevantAppointments);
              
              if (accessResult.canAccess) {
                final primaryAppointment = ChatAccessService.getRelevantAppointment(relevantAppointments);
                print("[ChatAccessBloc] ✅ Access granted");
                return ChatAccessAllowed(
                  relevantAppointments: relevantAppointments,
                  primaryAppointment: primaryAppointment,
                );
              } else {
                print("[ChatAccessBloc] ❌ Access denied: ${accessResult.message}");
                return ChatAccessDenied(
                  reason: accessResult.message,
                  appointments: relevantAppointments,
                );
              }
            },
          );
        },
        onError: (error, stackTrace) {
          print("[ChatAccessBloc] 💥 Stream error: $error");
          return ChatAccessError(error.toString());
        },
      );
    } catch (e) {
      print("[ChatAccessBloc] 💥 Exception: $e");
      emit(ChatAccessError(e.toString()));
    }
  }
}