import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/features/auth/presentation/home/home_screen.dart';
import 'package:health_connect/features/auth/presentation/profile/screen/profile_screen.dart';
import '../cubit/bottom_nav_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Widget> screens = const [
    HomeScreen(),
    Text("Survey Screen"),
    Text("Chat Screen"),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavCubit(),
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            body: screens[currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) =>
                  context.read<BottomNavCubit>().changeTab(index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.grey,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 24.r),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment, size: 24.r),
                  label: 'Survey',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline, size: 24.r),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 24.r),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
