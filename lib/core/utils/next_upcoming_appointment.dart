import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

AppointmentEntity? findNextUpcomingAppointment(List<AppointmentEntity> appointments) {
  try {
    // Pehle, 'confirmed' aur future appointments ko dhoondein
    final upcomingConfirmed = appointments.where(
      (a) => a.appointmentDateTime.isAfter(DateTime.now()) && a.status == 'confirmed',
    );
    
    // Agar koi mila, to usmein se pehla wala return karein
    if (upcomingConfirmed.isNotEmpty) {
      return upcomingConfirmed.first;
    }
    
    // Agar koi upcoming nahi mila, to fallback ke taur par sabse naya appointment return karein
    if (appointments.isNotEmpty) {
      return appointments.first; // List pehle se hi date descending mein sorted hai
    }
    
    // Agar koi bhi appointment nahi hai
    return null;
  } catch (e) {
    // 'firstWhere' crash ho sakta hai agar list khali ho, isliye try-catch behtar hai
    return null;
  }
}