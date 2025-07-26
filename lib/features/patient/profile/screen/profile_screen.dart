import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/patient/appointment/presentation/screen/patient_appointment_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get the current theme state
    final isDark = context.watch<ThemeCubit>().state.isDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        // Use theme colors for consistency
        backgroundColor: theme.appBarTheme.backgroundColor,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          // Section: General
          _buildSectionHeader(context, "General"),
          const SizedBox(height: 10),

          // Theme Toggle Switch
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'Enabled' : 'Disabled'),
            value: isDark,
            onChanged: (value) {
              // Call the ThemeCubit to toggle the theme
              context.read<ThemeCubit>().toggleTheme();
            },
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: theme.colorScheme.primary,
            ),
            activeColor: theme.colorScheme.primary,
          ),

          const Divider(height: 30, indent: 16, endIndent: 16),

          // Section: Account
          _buildSectionHeader(context, "Account"),
          const SizedBox(height: 10),

          // Edit Profile Option
          ListTile(
            leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your personal details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Create and navigate to PatientEditProfileScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit Profile screen coming soon!")),
              );
            },
          ),
          
          // My Appointments Option
           ListTile(
            leading: Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
            title: const Text('My Appointments'),
            subtitle: const Text('View your appointment history'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const PatientAppointmentsScreen(),
              ));
            },
          ),

          // Logout Option
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: const Text('Logout'),
            subtitle: const Text('Sign out from your account'),
            onTap: () {
              // Show a confirmation dialog before logging out
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
                        // Add the LogoutRequested event to AuthBloc
                        context.read<AuthBloc>().add(LogoutRequested());
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text('Logout', style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to create section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}