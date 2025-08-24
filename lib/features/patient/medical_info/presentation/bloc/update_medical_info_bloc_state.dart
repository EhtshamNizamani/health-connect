
import 'package:equatable/equatable.dart';

abstract class UpdateMedicalInfoState extends Equatable {
  const UpdateMedicalInfoState();
  @override
  List<Object> get props => [];
}

class UpdateMedicalInfoInitial extends UpdateMedicalInfoState {}
class UpdateMedicalInfoSaving extends UpdateMedicalInfoState {}
class UpdateMedicalInfoSuccess extends UpdateMedicalInfoState {}
class UpdateMedicalInfoFailure extends UpdateMedicalInfoState {
  final String message;
  const UpdateMedicalInfoFailure(this.message);
  @override
  List<Object> get props => [message];
}