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
import 'package:health_connect/features/dashboard/screens/dashboard_screen.dart';
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
                  SizedBox(height: 80.h),

                  CustomTextWidget(
                    text: "Welcome Back!",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextWidget(
                    text: "Please login to your account",
                    fontSize: 14,
                    color: AppColors.grey,
                  ),

                  SizedBox(height: 32.h),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                      buttonName: "Forgot Password?",
                      onPressed: () {},
                      textColor: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  CustomButton(
                    textColor: AppColors.white,
                    text: 'Login',
                    isLoading: state is AuthLoading,
                    onTap: () {
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
                      color: AppColors.grey,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  CustomButton(
                    text: 'Login with Google',
                    textColor: AppColors.primary,
                    onTap: () {
                      // TODO: Implement Google Sign-In
                    },
                    isBorder: true,
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextWidget(
                        text: "Don't have an account?",
                        fontSize: 14,
                      ),
                      CustomTextButton(
                        buttonName: "Sign Up",
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ));
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
