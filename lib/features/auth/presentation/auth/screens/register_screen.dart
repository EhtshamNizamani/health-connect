import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/custom_text_widget.dart';
import 'package:health_connect/core/shared/widgets/custom_textbutton.dart';
import 'package:health_connect/core/shared/widgets/custom_textfield.dart';
import 'package:health_connect/core/utils/form_validator.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selectedRole = 'patient'; // default role
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return Scaffold(
      // Use scaffoldBackgroundColor from the theme
      backgroundColor: theme.scaffoldBackgroundColor,
      // Add an AppBar for back navigation
      appBar: AppBar(
        scrolledUnderElevation:0,
          
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onBackground),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Use SingleChildScrollView to prevent overflow
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
                // Navigation is handled globally, so no need for it here.
              },
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    const CustomTextWidget(
                      text: "Create Account",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8.h),
                    CustomTextWidget(
                      text: "Fill the details below to register",
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),

                    SizedBox(height: 32.h),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            hintText: 'Full Name',
                            keyboardType: TextInputType.name,
                            validator: FormValidator.validateName,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: emailController,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: FormValidator.validateEmail,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            isObscure: _isPasswordObscured,
                            maxLines: 1,
                            validator: FormValidator.validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.colorScheme.outline,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Role Selection (Styled with Theme)
                          const CustomTextWidget(
                            text: "I am a:",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              _buildRoleSelector(
                                context: context,
                                title: 'Patient',
                                value: 'patient',
                              ),
                              SizedBox(width: 16.w),
                              _buildRoleSelector(
                                context: context,
                                title: 'Doctor',
                                value: 'doctor',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    CustomButton(
                      text: 'Sign Up',
                      isLoading: state is AuthLoading,
                      onTap: () {
                        if (state is AuthLoading) return;
                        if (_formKey.currentState!.validate()) {
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          context.read<AuthBloc>().add(
                            RegisterRequested(
                              name: name,
                              email: email,
                              password: password,
                              selectedRole: selectedRole,
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 24.h),

                    // ... (OR and Google Button section)

                    // No need for a Spacer if we use SingleChildScrollView
                    SizedBox(height: 24.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextWidget(
                          text: "Already have an account? ",
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        CustomTextButton(
                          buttonName: "Login",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          textColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build a styled role selector
  Widget _buildRoleSelector({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = selectedRole == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: value,
                groupValue: selectedRole,
                onChanged: (val) {
                  setState(() {
                    selectedRole = val!;
                  });
                },
                // Use theme colors for the radio button
                activeColor: theme.colorScheme.primary,
              ),
              CustomTextWidget(
                text: title,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
