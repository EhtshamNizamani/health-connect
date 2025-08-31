import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/core/shared/widgets/custom_textfield.dart';
import 'package:health_connect/core/utils/form_validator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/patient/profile/presantation/bloc/patient_profile_bloc.dart';
import 'package:health_connect/features/patient/profile/presantation/bloc/patient_profile_event.dart';
import 'package:health_connect/features/patient/profile/presantation/bloc/patient_profile_state.dart';
// Image picker ke liye
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _ageController;
  String? _selectedGender;
  
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    print("context.read<AuthBloc>().state ${context.read<AuthBloc>().state}");
    _nameController = TextEditingController(text: user?.name ?? '');
    _allergiesController = TextEditingController(text: user?.allergies ?? '');
    _conditionsController = TextEditingController(text: user?.chronicConditions ?? '');
    _ageController = TextEditingController(text: user?.age ?? '');
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    // Dispose all controllers
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final pickedXFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedXFile != null) {
      setState(() {
        _pickedImageFile = File(pickedXFile.path);
      });
    }
  }

 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => sl<PatientProfileBloc>(),
      child: Scaffold(
        // <<< --- THE FIX: We use MultiBlocListener to coordinate between BLoCs ---
        body: MultiBlocListener(
          listeners: [
            // Listener #1: Listens to the local PatientProfileBloc
            BlocListener<PatientProfileBloc, PatientProfileState>(
              listener: (context, state) {
                // This listener now ONLY handles showing the failure message.
                // Success is handled by the AuthBloc listener below.
                if (state is PatientProfileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
            ),
            // Listener #2: Listens to the GLOBAL AuthBloc
            BlocListener<AuthBloc, AuthState>(
              // Only listen when the state changes from some form of loading/saving to authenticated.
              listenWhen: (previous, current) =>
                  (previous is AuthLoading || context.read<PatientProfileBloc>().state is PatientProfileSaving) &&
                  current is AuthenticatedPatient,
              listener: (context, authState) {
                // This will trigger AFTER the PatientProfileBloc has successfully
                // told the AuthBloc to refresh, and the AuthBloc has finished.
                final profileState = context.read<PatientProfileBloc>().state;
                if (profileState is PatientProfileSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
                  );
                  // NOW it's safe to pop, because the previous screen
                  // will get the updated user data from the refreshed AuthBloc.
                  Navigator.pop(context);
                }
              },
            ),
          ],
          // The main UI is built by the local PatientProfileBloc
          child: BlocBuilder<PatientProfileBloc, PatientProfileState>(
            builder: (context, state) {
              final isSaving = state is PatientProfileSaving;

              return Scaffold(
                appBar: AppBar(
                  title: const Text("Edit Profile"),
                  actions: [
                    if (isSaving)
                      const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          context.read<PatientProfileBloc>().add(
                                UpdateProfileButtonPressed(
                                  name: _nameController.text,
                                  photoFile: _pickedImageFile,
                                  allergies: _allergiesController.text,
                                  chronicConditions: _conditionsController.text,
                                  age: _ageController.text,
                                  gender: _selectedGender,
                                ),
                              );
                        },
                        child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                  ],
                ),
                body: AbsorbPointer(
                  absorbing: isSaving,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: _buildProfilePicture(context.read<AuthBloc>().state.user)),
                        const SizedBox(height: 32),
                        const _SectionTitle("Basic Information"),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          prefixIcon: CupertinoIcons.person_fill,
                          validator: FormValidator.validateName,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _ageController,
                                hintText: 'Age',
                                prefixIcon: CupertinoIcons.number,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildGenderDropdown(theme)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const _SectionTitle("Medical Information"),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _allergiesController,
                          hintText: 'Allergies (e.g., Penicillin, Peanuts)',
                          prefixIcon: CupertinoIcons.bandage_fill,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _conditionsController,
                          hintText: 'Chronic Conditions (e.g., Asthma)',
                          prefixIcon: CupertinoIcons.heart_fill,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildProfilePicture(UserEntity? currentUser) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(currentUser.photoUrl!)
                  : null as ImageProvider?,
          child: (_pickedImageFile == null && (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty))
              ? const Icon(CupertinoIcons.person_fill, size: 60)
              : null,
        ),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(CupertinoIcons.camera_fill, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGenderDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        prefixIcon: Icon(
          _selectedGender == 'Male' ? Icons.male : _selectedGender == 'Female' ? Icons.female : Icons.transgender,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      items: ['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}