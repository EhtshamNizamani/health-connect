import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/constants/app_color.dart'; // Apne app colors ke liye
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart'; // AuthBloc import karein
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart'; // AuthEvent import karein


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeCubit se current theme state haasil karein
    final bool isDark = context.watch<ThemeCubit>().state.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          // Section: General
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          
          // Theme Toggle Switch
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'Enabled' : 'Disabled'),
            value: isDark,
            onChanged: (value) {
              // ThemeCubit ke toggleTheme method ko call karein
              context.read<ThemeCubit>().toggleTheme();
            },
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            activeColor: AppColors.primary,
          ),

          const Divider(height: 30, indent: 16, endIndent: 16),
          
          // Section: Account
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          // Edit Profile Option
          ListTile(
            leading: Icon(Icons.edit, color: AppColors.primary),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your personal and professional details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Jab aap 'UpdateDoctorProfileScreen' bana lein,
              // to yahan se us par navigate karein.
              /*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdateDoctorProfileScreen(),
                ),
              );
              */
              
              // Abhi ke liye ek SnackBar dikha dein
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit Profile Screen coming soon!")),
              );
            },
          ),
          
          // Logout Option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            subtitle: const Text('Sign out from your account'),
            onTap: () {
              // Confirmation dialog dikhayein
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(), // Dialog band karein
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // AuthBloc mein LogoutRequested event add karein
                        context.read<AuthBloc>().add(LogoutRequested());
                        Navigator.of(dialogContext).pop(); // Dialog band karein
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
}