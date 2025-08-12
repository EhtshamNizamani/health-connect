import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/shared/widgets/notification_badge_icon.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:health_connect/features/patient/home/presentation/screen/home_screen.dart';
import 'package:health_connect/features/patient/patient_setings/screen/patient_setings_screen.dart';
import '../cubit/bottom_nav_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Widget> screens = const [
    PatientHomeScreen(),
    Text("Survey Screen"),
    ChatListScreen(),
    PatientSettingsScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => BottomNavCubit(),
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            // Use IndexedStack to keep the state of each screen alive
            // when switching tabs. This is much more efficient.
            body: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) =>
                  context.read<BottomNavCubit>().changeTab(index),
              
              // === THEME STYLING ===
              backgroundColor: theme.colorScheme.surface,
              type: BottomNavigationBarType.fixed,
              
              // Selected item styling
              selectedItemColor: theme.colorScheme.primary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              
              // Unselected item styling
              unselectedItemColor: theme.colorScheme.outline,
              showUnselectedLabels: true,
              
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 24.r),
                  activeIcon: Icon(Icons.home, size: 24.r),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined, size: 24.r),
                  activeIcon: Icon(Icons.assignment, size: 24.r),
                  label: 'Survey',
                ),
                BottomNavigationBarItem(
                  icon: NotificationBadgeIcon(
                    iconData: Icons.chat_bubble_outline,
                    size: 24.r,
                    type: NotificationBadgeType.messages,
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 24.r),
                  activeIcon: Icon(Icons.person, size: 24.r),
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