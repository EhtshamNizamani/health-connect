import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/label_textfield.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/presantation/bloc/doctor_profile_update_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/presantation/bloc/doctor_profile_update_event.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/presantation/bloc/doctor_profile_update_state.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfileUpdateScreen extends StatelessWidget {
  const DoctorProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC and fetch data immediately
    return BlocProvider(
      create: (context) =>
          sl<DoctorProfileUpdateBloc>()..add(FetchDoctorProfileForUpdate()),
      child: const DoctorProfileUpdateView(),
    );
  }
}

class DoctorProfileUpdateView extends StatefulWidget {
  const DoctorProfileUpdateView({super.key});

  @override
  State<DoctorProfileUpdateView> createState() =>
      _DoctorProfileUpdateViewState();
}

class _DoctorProfileUpdateViewState extends State<DoctorProfileUpdateView> {
  // Controllers for all the form fields
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final consultationFeeController = TextEditingController();

  // To store the current doctor's data
  DoctorEntity? _currentDoctor;
  File? _newPhotoFile;

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    // ... dispose all controllers
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _newPhotoFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
      body: BlocConsumer<DoctorProfileUpdateBloc, DoctorProfileUpdateState>(
        listener: (context, state) {
          if (state is DoctorProfileUpdateLoaded) {
            // Pre-fill the form fields when data is loaded
            final doctor = state.doctor;
            _currentDoctor = doctor;
            nameController.text = doctor.name;
            specializationController.text = doctor.specialization;
            experienceController.text = doctor.experience.toString();
            consultationFeeController.text = doctor.consultationFee.toString();
            clinicAddressController.text = doctor.clinicAddress;
            bioController.text = doctor.bio;
          }
          if (state is DoctorProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully!")),
            );
            Navigator.of(context).pop();
          }
          if (state is DoctorProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DoctorProfileUpdateLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DoctorProfileUpdateLoaded ||
              state is DoctorProfileUpdating ||
              state is DoctorProfileUpdateFailure) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // --- Image Picker ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      backgroundImage: _newPhotoFile != null
                          ? FileImage(_newPhotoFile!)
                          : (_currentDoctor?.photoUrl.isNotEmpty ?? false)
                          ? CachedNetworkImageProvider(_currentDoctor!.photoUrl)
                          : null,
                      child:
                          (_newPhotoFile == null &&
                              (_currentDoctor?.photoUrl.isEmpty ?? true))
                          ? const Icon(Icons.camera_alt)
                          : null,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // --- Form Fields ---
                  LabeledTextField(
                    controller: nameController,
                    label: "Full Name",
                    hintText: "Enter your full name",
                  ),
                  SizedBox(height: 16.h),
                  LabeledTextField(
                    controller: specializationController,
                    label: "Specialization",
                    hintText: "e.g., Cardiologist",
                  ),
                  SizedBox(height: 16.h),
                  LabeledTextField(
                    controller: experienceController,
                    label: "Experience (in years)",
                    hintText: "e.g., 10",
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  LabeledTextField(
                    controller: consultationFeeController,
                    label: "Consultation Fee",
                    hintText: "e.g., 2000",
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  LabeledTextField(
                    controller: clinicAddressController,
                    label: "Clinic Address",
                    hintText: "Enter the full clinic address",
                  ),
                  SizedBox(height: 16.h),
                  LabeledTextField(
                    controller: bioController,
                    label: "About Yourself (Bio)",
                    hintText: "Write a short bio...",
                    maxLines: 4,
                  ),
                  SizedBox(height: 32.h),

                  // --- Update Button ---
                  CustomButton(
                    text: "Save Changes",
                    isLoading: state is DoctorProfileUpdating,
                    onTap: () {
                      if (_currentDoctor != null) {
                        context.read<DoctorProfileUpdateBloc>().add(
                          SubmitProfileUpdate(
                            uid: _currentDoctor!.uid,
                            name: nameController.text,
                            specialization: specializationController.text,
                            bio: bioController.text,
                            experience:
                                int.tryParse(experienceController.text) ?? 0,
                            clinicAddress: clinicAddressController.text,
                            consultationFee:
                                int.tryParse(consultationFeeController.text) ??
                                0,
                            existingPhotoUrl: _currentDoctor!.photoUrl,
                            newPhotoFile: _newPhotoFile,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text("Loading profile..."),
          ); // Initial state
        },
      ),
    );
  }
}
