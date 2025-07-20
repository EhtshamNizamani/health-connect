import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/custom_text_widget.dart';
import 'package:health_connect/core/shared/widgets/custom_textbutton.dart';
import 'package:health_connect/core/shared/widgets/custom_textfield.dart';
import 'package:health_connect/core/utils/form_validator.dart';
import 'package:health_connect/features/dashboard/screens/dashboard_screen.dart';
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
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Welcome UID: ${state.user.id}')),
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
              
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60.h),

                  CustomTextWidget(
                    text: "Create Account",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextWidget(
                    text: "Fill the details below to register",
                    fontSize: 14,
                    color: AppColors.grey,
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
                          maxLine: 1,
                          validator: FormValidator.validatePassword,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  CustomButton(
                    textColor: AppColors.white,
                    text: 'Sign Up',
                    isLoading: state is AuthLoading,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        context.read<AuthBloc>().add(
                          RegisterRequested(
                            name: name,
                            email: email,
                            password: password,
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 24.h),

                  Center(
                    child: CustomTextWidget(
                      text: "OR",
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  CustomButton(
                    text: 'Continue with Google',
                    textColor: AppColors.primary,
                    onTap: () {
                      // TODO: Implement Google Sign-Up
                    },
                    isBorder: true,
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextWidget(
                        text: "Already have an account?",
                        fontSize: 14,
                      ),
                      CustomTextButton(
                        buttonName: "Login",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        textColor: AppColors.primary,
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
