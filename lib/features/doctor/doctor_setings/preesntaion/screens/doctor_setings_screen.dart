import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart'; // AuthBloc import karein
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/presantation/screen/doctor_profile_update_screen.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/screen/manage_availability_screen.dart';
import 'package:health_connect/features/doctor/doctor_setings/preesntaion/widgets/section_header.dart';
import 'package:health_connect/features/doctor/doctor_setings/preesntaion/widgets/setings_tile.dart'; // AuthEvent import karein

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeCubit>().state.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Section: General
          const SectionHeader(title: "General"),

          // Theme Toggle Switch
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'Enabled' : 'Disabled'),
            value: isDark,
            onChanged: (value) => context.read<ThemeCubit>().toggleTheme(),
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: theme.colorScheme.primary,
            ),
            activeColor: theme.colorScheme.primary,
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // Section: Account & Profile
          const SectionHeader(title: "Account & Profile"),

          // <<< --- NAYA OPTION YAHAN ADD HOGA ---
          SettingsTile(
            icon: Icons.calendar_month_outlined,
            iconColor: theme.colorScheme.primary,
            title: "Manage Availability",
            subtitle: "Set your weekly working hours",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageAvailabilityScreen(),
                ),
              );
            },
          ),

          // <<< -----------------------------------
          SettingsTile(
            icon: Icons.edit_outlined,
            iconColor: theme.colorScheme.primary,
            title: "Update Profile",
            subtitle: "Update your personal and professional details",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DoctorProfileUpdateScreen(),
                ),
              );
            },
          ),

          SettingsTile(
            icon: Icons.logout,
            iconColor: theme.colorScheme.error,
            title: "Logout",
            subtitle: "Sign out from your account",
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  // Helper method for the logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
