// doctor_profile_setup_screen.dart (CLEAN ARCHITECTURE)

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/screen/doctor_main_screen.dart';
import 'package:health_connect/features/doctor/home/doctor_home_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_event.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/custom_textfield.dart';

class DoctorProfileSetupScreen extends StatefulWidget {
  const DoctorProfileSetupScreen({super.key});

  @override
  State<DoctorProfileSetupScreen> createState() => _DoctorProfileSetupScreenState();
}

class _DoctorProfileSetupScreenState extends State<DoctorProfileSetupScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final clinicAddressController = TextEditingController();
  final consultationFeeController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  File? pickedImage;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }

  Future<void> pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: BlocConsumer<DoctorProfileSetupBloc, DoctorProfileSetupState>(
        listener: (ctx, state) {
          print("DoctorProfileSetupBloc state: $state");
          // Use a short delay to prevent build-cycle errors
          if (state is DoctorProfileSuccess) {
            Future.delayed(const Duration(milliseconds: 100), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile saved successfully!")),
              );
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const DoctorMainScreen()));
            });
          } else if (state is DoctorProfileFailure) {
            Future.delayed(const Duration(milliseconds: 100), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}")),
              );
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
                      child: pickedImage == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(controller: nameController, hintText: "Full Name"),
                const SizedBox(height: 16),
                CustomTextField(controller: specializationController, hintText: "Specialization (e.g., Cardiologist)"),
                const SizedBox(height: 16),
                CustomTextField(controller: experienceController, hintText: "Experience (years)", keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                CustomTextField(controller: consultationFeeController, hintText: "Consultation Fee", keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                CustomTextField(controller: clinicAddressController, hintText: "Clinic Address"),
                const SizedBox(height: 16),
                CustomTextField(controller: bioController, hintText: "A short bio about yourself", maxLine: 3),
                const SizedBox(height: 16),
                const Text("Set Available Timings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: startTime != null ? "Start: ${startTime!.format(context)}" : "Select Start Time",
                        onTap: () => pickTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: endTime != null ? "End: ${endTime!.format(context)}" : "Select End Time",
                        onTap: () => pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: "Save Profile",
                  isLoading: state is DoctorProfileLoading, // Make sure your state is named this or similar
                  onTap: () {
                    if (nameController.text.isEmpty ||
                        specializationController.text.isEmpty ||
                        startTime == null ||
                        endTime == null ||
                        pickedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all mandatory fields and pick an image.")),
                      );
                      return;
                    }

                    final String startTimeString = startTime!.format(context);
                    final String endTimeString = endTime!.format(context);

                    // Assume the email comes from the currently authenticated user
                    // In a real app, you might fetch this from FirebaseAuth.instance.currentUser.email
                    // The BLoC event doesn't need the email if the repository can get it.
                    
                    context.read<DoctorProfileSetupBloc>().add(
                          SubmitDoctorProfile(
                            name: nameController.text,
                            email: "", // Let repository handle this from auth
                            specialization: specializationController.text,
                            bio: bioController.text,
                            experience: int.tryParse(experienceController.text) ?? 0,
                            consultationFee: int.tryParse(consultationFeeController.text) ?? 0,
                            clinicAddress: clinicAddressController.text,
                            startTime: startTimeString,
                            endTime: endTimeString,
                            photoFile: pickedImage,
                          ),
                        );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    clinicAddressController.dispose();
    consultationFeeController.dispose();
    super.dispose();
  }
}