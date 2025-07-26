
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/repositroy/doctor_profile_view_repository.dart';
import 'package:intl/intl.dart';

class GetAvailableSlotsUseCase {
  final DoctorProfileViewRepository doctorProfileViewRepository;
  // You can make the slot duration configurable
  final int slotDurationInMinutes = 30;

  GetAvailableSlotsUseCase(this.doctorProfileViewRepository);

  Future<Either<Failure, List<DateTime>>> call(String doctorId, DateTime date) async {
    try {
      // 1. Get Doctor's weekly schedule
      final doctorResult = await doctorProfileViewRepository.getDoctorById(doctorId);
      final doctor = doctorResult.getOrElse(() => throw Exception("Doctor not found"));

      // 2. Get the day of the week (e.g., "monday")
      final dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
      final dailyAvailability = doctor.weeklyAvailability[dayOfWeek];

      if (dailyAvailability == null || !dailyAvailability.isWorking) {
        return const Right([]); // Doctor is not working on this day
      }

      // 3. Generate all possible slots for the day
      List<DateTime> allPossibleSlots = [];
      for (final timeSlot in dailyAvailability.slots) {
        DateTime startTime = DateFormat("HH:mm").parse(timeSlot.startTime);
        DateTime endTime = DateFormat("HH:mm").parse(timeSlot.endTime);

        DateTime currentSlot = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
        DateTime finalSlot = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

        while (currentSlot.isBefore(finalSlot)) {
          allPossibleSlots.add(currentSlot);
          currentSlot = currentSlot.add(Duration(minutes: slotDurationInMinutes));
        }
      }

      // 4. Get already booked slots
      final bookedSlotsResult = await doctorProfileViewRepository.getAvailableSlots(doctorId, date);
      final bookedSlots = bookedSlotsResult.getOrElse(() => []);

      // 5. Filter out the booked slots
      final availableSlots = allPossibleSlots.where((slot) {
        // Also filter out past slots for today
        if (date.day == DateTime.now().day && slot.isBefore(DateTime.now())) {
          return false;
        }
        return !bookedSlots.any((booked) => booked.isAtSameMomentAs(slot));
      }).toList();

      return Right(availableSlots);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}