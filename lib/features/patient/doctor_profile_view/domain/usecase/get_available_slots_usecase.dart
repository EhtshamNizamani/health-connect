
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/repositroy/doctor_profile_view_repository.dart';
import 'package:intl/intl.dart';

class GetAvailableSlotsUseCase {
  // <<< --- CHANGE #2: Depend on the two correct repositories ---
  final DoctorProfileViewRepository doctorRepository;
  final AppointmentRepository appointmentRepository;
  final int slotDurationInMinutes = 30;

  // Update the constructor to accept both repositories
  GetAvailableSlotsUseCase(
     this.doctorRepository,
     this.appointmentRepository,
  );

  Future<Either<Failure, List<DateTime>>> call(String doctorId, DateTime date) async {
    try {

      final doctorResult = await doctorRepository.getDoctorById(doctorId);
      
      // Use fold for safer error handling
      return await doctorResult.fold(
        (failure) => Left(failure), // If doctor fetch fails, stop here
        (doctor) async {
          // --- Step 2: Figure out which day of the week it is and if the doctor is working ---
          final dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
          final dailyAvailability = doctor.weeklyAvailability[dayOfWeek];

          if (dailyAvailability == null || !dailyAvailability.isWorking) {
            return const Right([]); // Return empty list if doctor is off
          }

          // --- Step 3: Generate all possible time slots based on the schedule ---
          List<DateTime> allPossibleSlots = [];
          for (final timeSlot in dailyAvailability.slots) {
            final startTime = DateFormat("HH:mm").parse(timeSlot.startTime);
            final endTime = DateFormat("HH:mm").parse(timeSlot.endTime);
            
            var currentSlot = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
            final finalSlotTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

            while (currentSlot.isBefore(finalSlotTime)) {
              allPossibleSlots.add(currentSlot);
              currentSlot = currentSlot.add(Duration(minutes: slotDurationInMinutes));
            }
          }

          // --- Step 4: Get the slots that are already booked for that day from AppointmentRepository ---
          final bookedSlotsResult = await appointmentRepository.getBookedSlots(doctorId, date);
          
          return bookedSlotsResult.fold(
            (failure) => Left(failure), // If booked slots fetch fails, stop here
            (bookedSlots) {
              // --- Step 5: Filter the possible slots, removing the ones that are booked or in the past ---
              
              // Use a Set of formatted strings for reliable and fast checking to prevent double booking
              final bookedTimeStrings = bookedSlots.map((dt) => DateFormat('HH:mm').format(dt)).toSet();

              final availableSlots = allPossibleSlots.where((slot) {
                // Filter out slots that are in the past for today's date
                if (date.isSameDateAs(DateTime.now()) && slot.isBefore(DateTime.now())) {
                  return false;
                }
                
                // The reliable check: is this slot's time string in our set of booked times?
                final slotTimeString = DateFormat('HH:mm').format(slot);
                return !bookedTimeStrings.contains(slotTimeString);
              }).toList();

              return Right(availableSlots); // Return the final list of available slots
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// Helper extension to compare dates without considering time
extension DateOnlyCompare on DateTime {
  bool isSameDateAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}