// chat_access_service.dart
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

class ChatAccessService {
  
  /// Check if chat icon should be visible on doctor profile
  static bool shouldShowChatIcon(List<AppointmentEntity> appointments) {
    if (appointments.isEmpty) return false;
    
    final now = DateTime.now();
    
    // Find relevant appointments between current patient and doctor
    for (final appointment in appointments) {
      // Show if appointment is pending or confirmed
      if (appointment.status == 'pending' || appointment.status == 'confirmed') {
        return true;
      }
      
      // Show if appointment is completed and within 2 days
      if (appointment.status == 'completed') {
        final completionDate = appointment.appointmentDateTime;
        final daysSinceCompletion = now.difference(completionDate).inDays;
        if (daysSinceCompletion <= 2) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Check if user can send messages in chat
  static ChatAccessResult canAccessChat(List<AppointmentEntity> appointments) {
    if (appointments.isEmpty) {
      return ChatAccessResult(
        canAccess: false,
        message: "Please book an appointment to start chatting with the doctor.",
      );
    }
    
    final now = DateTime.now();
    
    for (final appointment in appointments) {
      // Allow if appointment is pending or confirmed
      if (appointment.status == 'pending' || appointment.status == 'confirmed') {
        return ChatAccessResult(canAccess: true);
      }
      
      // Allow if appointment is completed and within 2 days
      if (appointment.status == 'completed') {
        final completionDate = appointment.appointmentDateTime;
        final daysSinceCompletion = now.difference(completionDate).inDays;
        if (daysSinceCompletion <= 2) {
          return ChatAccessResult(canAccess: true);
        }
      }
    }
    
    return ChatAccessResult(
      canAccess: false,
      message: "Your chat access has expired. Please book a new appointment to continue.",
    );
  }
  
  /// Get the most relevant appointment for chat access
  static AppointmentEntity? getRelevantAppointment(List<AppointmentEntity> appointments) {
    if (appointments.isEmpty) return null;
    
    final now = DateTime.now();
    
    // Priority 1: Confirmed appointments
    final confirmed = appointments.where((a) => a.status == 'confirmed').toList();
    if (confirmed.isNotEmpty) {
      confirmed.sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
      return confirmed.first;
    }
    
    // Priority 2: Pending appointments
    final pending = appointments.where((a) => a.status == 'pending').toList();
    if (pending.isNotEmpty) {
      pending.sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
      return pending.first;
    }
    
    // Priority 3: Recently completed appointments (within 2 days)
    final recentlyCompleted = appointments.where((a) {
      if (a.status != 'completed') return false;
      final daysSince = now.difference(a.appointmentDateTime).inDays;
      return daysSince <= 2;
    }).toList();
    
    if (recentlyCompleted.isNotEmpty) {
      recentlyCompleted.sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime));
      return recentlyCompleted.first;
    }
    
    return null;
  }
}

class ChatAccessResult {
  final bool canAccess;
  final String message;
  
  const ChatAccessResult({
    required this.canAccess,
    this.message = '',
  });
}