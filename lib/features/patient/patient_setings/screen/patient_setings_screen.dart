import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/label_textfield.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/patient/appointment/presentation/screen/patient_appointment_screen.dart';
import 'package:image_picker/image_picker.dart';

class PatientSettingsScreen extends StatelessWidget {
  const PatientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Use BlocBuilder to ensure the UI rebuilds when the user's name/photo changes
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Get the current user from the state
        UserEntity? currentUser;
        if (authState is AuthenticatedPatient) {
          currentUser = authState.user;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Settings & Profile'),
            backgroundColor: theme.appBarTheme.backgroundColor,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            children: [
              // --- PROFILE HEADER WIDGET ---
              // Only show the header if the user is properly authenticated
              if (currentUser != null)
                _ProfileHeader(
                  user: currentUser,
                  onTap: () => _showEditProfileSheet(context, currentUser!),
                ),

              const SizedBox(height: 20),

              // --- General Section ---
              _buildSectionHeader(context, "General"),
              const SizedBox(height: 10),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(themeState.isDark ? 'Enabled' : 'Disabled'),
                    value: themeState.isDark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    secondary: Icon(
                      themeState.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
              const Divider(height: 30, indent: 16, endIndent: 16),
              
              // --- Account Section ---
              _buildSectionHeader(context, "Account"),
              const SizedBox(height: 10),
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
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: const Text('Logout'),
                subtitle: const Text('Sign out from your account'),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Method for the Bottom Sheet ---
  void _showEditProfileSheet(BuildContext context, UserEntity currentUser) {
    final nameController = TextEditingController(text: currentUser.name);
    File? newPhotoFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Use StatefulBuilder to manage the state of the photo picker within the sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return BlocListener<AuthBloc, AuthState>(
              // Add a listener to close the sheet on success
              listener: (context, state) {
                if (state is AuthenticatedPatient && state.user.name == nameController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully!")),
                  );
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20, right: 20, top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Update Your Profile", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (pickedFile != null) {
                          setModalState(() {
                            newPhotoFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: newPhotoFile != null
                            ? FileImage(newPhotoFile!)
                            : (currentUser.photoUrl != null && currentUser.photoUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(currentUser.photoUrl!)
                                : null,
                        child: (newPhotoFile == null && (currentUser.photoUrl == null || currentUser.photoUrl!.isEmpty))
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Name Field
                    LabeledTextField(
                      controller: nameController,
                      label: "Full Name",
                      hintText: "Enter your full name",
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text: "Save Changes",
                          isLoading: state is AuthLoading,
                          onTap: () {
                            // Dispatch the update event to the AuthBloc
                            context.read<AuthBloc>().add(UpdateUserProfile(
                                  uid: currentUser.id,
                                  name: nameController.text.trim(),
                                  photoFile: newPhotoFile,
                                ));
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  // Helper for Logout Dialog
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
            child: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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

// --- PROFILE HEADER WIDGET ---
class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const _ProfileHeader({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Profile Photo
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? Icon(Icons.person, size: 30, color: theme.colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              // Name and "Edit Profile" text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to edit your profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Icon
              Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}