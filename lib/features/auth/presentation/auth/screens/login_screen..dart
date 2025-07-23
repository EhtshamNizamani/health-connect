import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/custom_text_widget.dart';
import 'package:health_connect/core/shared/widgets/custom_textbutton.dart';
import 'package:health_connect/core/shared/widgets/custom_textfield.dart';
import 'package:health_connect/core/utils/form_validator.dart';
import 'package:health_connect/features/auth/presentation/auth/screens/register_screen.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/screen/doctor_main_screen.dart';
import 'package:health_connect/features/doctor/home/doctor_home_screen.dart';
import 'package:health_connect/features/patient/dashboard/screens/dashboard_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/screens/doctor_profile_setup_screen.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return Scaffold(
      // Use scaffoldBackgroundColor from the theme
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80.h),

                  // CustomTextWidget should ideally use theme.textTheme by default
                  const CustomTextWidget(
                    text: "Welcome Back!",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextWidget(
                    text: "Please login to your account",
                    fontSize: 14,
                    // Use a secondary text color from the theme
                    color: theme.textTheme.bodyMedium?.color,
                  ),

                  SizedBox(height: 32.h),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Assume CustomTextField is also theme-aware
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
                          isObscure: true, // Passwords should be obscured
                          maxLine: 1,
                          validator: FormValidator.validatePassword,
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                      buttonName: "Forgot Password?",
                      onPressed: () {},
                      // The text color should come from the theme's primary color
                      textColor: theme.colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  CustomButton(
                    // These properties should be handled by CustomButton's internal logic
                    // based on its theme. Let's assume it uses theme.colorScheme.onPrimary for text.
                    text: 'Login',
                    isLoading: state is AuthLoading,
                    onTap: () {
                      if (state is AuthLoading) return;
                      if (_formKey.currentState!.validate()) {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        context.read<AuthBloc>().add(
                              LoginRequested(email: email, password: password),
                            );
                      }
                    },
                  ),

                  SizedBox(height: 24.h),

                  Center(
                    child: CustomTextWidget(
                      text: "OR",
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // This is an outlined/secondary button
                  CustomButton(
                    text: 'Login with Google',
                    // textColor should be handled by CustomButton's theme
                    onTap: () {
                      // TODO: Implement Google Sign-In
                    },
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // This widget should use the default text color from the theme
                       CustomTextWidget(
                        text: "Don't have an account? ",
                        fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,

                      ),
                      CustomTextButton(
                        buttonName: "Sign Up",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        // The text color should come from the theme's primary/accent color
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
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}