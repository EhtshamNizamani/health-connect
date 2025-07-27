abstract class DoctorListEvent {}

class FetchDoctorsList extends DoctorListEvent{}

class SearchQueryChanged extends DoctorListEvent{
  final String query;
  SearchQueryChanged(this.query);
}