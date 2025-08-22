import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/patient/medical_info/presentation/bloc/update_medical_info_bloc_bloc.dart';
import 'package:health_connect/features/patient/medical_info/presentation/bloc/update_medical_info_bloc_event.dart';
import 'package:health_connect/features/patient/medical_info/presentation/bloc/update_medical_info_bloc_state.dart';

class EditMedicalInfoScreen extends StatefulWidget {
  const EditMedicalInfoScreen({super.key});

  @override
  State<EditMedicalInfoScreen> createState() => _EditMedicalInfoScreenState();
}

class _EditMedicalInfoScreenState extends State<EditMedicalInfoScreen> {
  // Controllers aur local state form ke liye
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _ageController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // AuthBloc se initial data lein
    final user = context.read<AuthBloc>().state.user;
    _allergiesController = TextEditingController(text: user?.allergies ?? '');
    _conditionsController = TextEditingController(text: user?.chronicConditions ?? '');
    _ageController = TextEditingController(text: user?.age ?? '');
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen ke top par BLoC provide karein
    return BlocProvider(
      create: (context) => sl<UpdateMedicalInfoBloc>(),
      child: BlocConsumer<UpdateMedicalInfoBloc, UpdateMedicalInfoState>(
        listener: (context, state) {
          // Listen for success or failure states
          if (state is UpdateMedicalInfoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Medical info updated successfully!"), backgroundColor: Colors.green),
            );
            // Navigate back after success
            Navigator.pop(context);
          }
          if (state is UpdateMedicalInfoFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final bool isSaving = state is UpdateMedicalInfoSaving;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit Medical Info"),
              actions: [
                // Save button with loading indicator
                if (isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      // Dispatch the event to the BLoC with the form's current data
                      context.read<UpdateMedicalInfoBloc>().add(
                        UpdateInfoButtonPressed(
                          allergies: _allergiesController.text,
                          chronicConditions: _conditionsController.text,
                          age: _ageController.text,
                          gender: _selectedGender,
                        ),
                      );
                    },
                  )
              ],
            ),
            // AbsorbPointer prevents user interaction while saving
            body: AbsorbPointer(
              absorbing: isSaving,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(labelText: "Allergies", hintText: "e.g., Penicillin, Peanuts"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conditionsController,
                      decoration: const InputDecoration(labelText: "Chronic Conditions", hintText: "e.g., Asthma, High Blood Pressure"),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(labelText: "Age"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(labelText: "Gender"),
                            items: ['Male', 'Female', 'Other'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}