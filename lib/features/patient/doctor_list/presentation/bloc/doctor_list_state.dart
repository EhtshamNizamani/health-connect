import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:equatable/equatable.dart';

// Using a single state class is a modern and clean BLoC pattern
class DoctorListState extends Equatable {
  final List<DoctorEntity> doctors;
  final bool isLoadingFirstPage;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final DocumentSnapshot? lastDocument;
  final String? errorMessage;

  const DoctorListState({
    this.doctors = const [],
    this.isLoadingFirstPage = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.lastDocument,
    this.errorMessage,
  });

  // Initial state factory
  factory DoctorListState.initial() => const DoctorListState();

  // copyWith method to easily create new states
  DoctorListState copyWith({
    List<DoctorEntity>? doctors,
    bool? isLoadingFirstPage,
    bool? isLoadingMore,
    bool? hasReachedMax,
    DocumentSnapshot? lastDocument,
    String? errorMessage,
  }) {
    return DoctorListState(
      doctors: doctors ?? this.doctors,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastDocument: lastDocument ?? this.lastDocument,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    doctors, isLoadingFirstPage, isLoadingMore, hasReachedMax, lastDocument, errorMessage
  ];
}