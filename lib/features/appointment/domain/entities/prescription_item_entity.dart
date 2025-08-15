import 'package:equatable/equatable.dart';

/// Represents a single item in a doctor's prescription.
class PrescriptionItemEntity extends Equatable {
  final String medicine;
  final String dosage;
  final String? instructions; // Optional instructions

  const PrescriptionItemEntity({
    required this.medicine,
    required this.dosage,
    this.instructions,
  });

  @override
  List<Object?> get props => [medicine, dosage, instructions];
}