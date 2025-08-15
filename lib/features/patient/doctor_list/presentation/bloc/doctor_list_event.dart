import 'package:equatable/equatable.dart';

abstract class DoctorListEvent extends Equatable {
  const DoctorListEvent();
  @override
  List<Object> get props => [];
}

/// Fetches the very first page of doctors. Should be called once.
class FetchInitialDoctors extends DoctorListEvent {}

/// Fetches the next page of doctors when the user scrolls to the bottom.
class FetchMoreDoctors extends DoctorListEvent {}

/// (We will add search back later, as it complicates pagination)
class SearchQueryChanged extends DoctorListEvent {
  final String query;
  const SearchQueryChanged(this.query);
}