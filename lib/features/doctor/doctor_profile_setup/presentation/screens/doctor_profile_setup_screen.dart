// doctor_profile_setup_screen.dart (CLEAN ARCHITECTURE)

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/label_textfield.dart';
import 'package:health_connect/features/doctor/doctor_bottom_navigation/screen/doctor_main_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_event.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';

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
  File? pickedImage;

  Future<void> pickImage() async {
      print("Picked image path:");
try{

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
} catch (e) {
  print("Error picking image: $e");
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
                const SnackBar(backgroundColor: AppColors.primary, content: Text("Profile saved successfully!")),
              );
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const DoctorMainScreen()));
            });
          } else if (state is DoctorProfileFailure) {
            Future.delayed(const Duration(milliseconds: 100), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: AppColors.error, content: Text("Error: ${state.message}")),
              );
            });
          }
        },
        builder: (context, state) {
          print("pickedImage: $pickedImage");
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
                const SizedBox(height: 32),
                CustomButton(
                  text: "Save Profile",
                  isLoading: state is DoctorProfileLoading, // Make sure your state is named this or similar
                  onTap: () {
                    if (nameController.text.isEmpty ||
                        specializationController.text.isEmpty ||
                   
                        pickedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: AppColors.error, content: Text("Please fill all mandatory fields and pick an image.")),
                      );
                      return;
                    }


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