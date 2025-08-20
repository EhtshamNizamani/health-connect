import 'package:equatable/equatable.dart';

abstract class PatientRecordsEvent extends Equatable {
  const PatientRecordsEvent();
  @override
  List<Object> get props => [];
}

/// Fetches the initial list of all patients.
class FetchPatientRecords extends PatientRecordsEvent {}

/// Triggered when the text in the search bar changes.
class SearchQueryChanged extends PatientRecordsEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}

/// Triggered when a filter chip is selected.
class FilterChanged extends PatientRecordsEvent {
  final String filter; // e.g., "All", "Recently Active", "A-Z"
  const FilterChanged(this.filter);
  @override
  List<Object> get props => [filter];
}