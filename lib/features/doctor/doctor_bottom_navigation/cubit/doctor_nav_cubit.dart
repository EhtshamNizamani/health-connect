import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorBottomNavCubit extends Cubit<int> {
  // Shuruaati index 0 (Home Screen) hoga
  DoctorBottomNavCubit() : super(0);

  // Jab tab par click ho to index badalne ke liye function
  void changeTab(int index) => emit(index);
}