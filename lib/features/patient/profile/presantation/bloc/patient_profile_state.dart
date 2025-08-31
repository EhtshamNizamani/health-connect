
import 'package:equatable/equatable.dart';

abstract class PatientProfileState extends Equatable {
  const PatientProfileState();
  @override
  List<Object> get props => [];
}

class PatientProfileInitial extends PatientProfileState {}
class PatientProfileSaving extends PatientProfileState {}
class PatientProfileSuccess extends PatientProfileState {}
class PatientProfileFailure extends PatientProfileState {
  final String message;
  const PatientProfileFailure(this.message);
  @override
  List<Object> get props => [message];
}