import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/core/shared/widgets/custom_text_widget.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = "";
        print("Current state: $state");
        if (state is Authenticated) {
          displayName = state.user.name.isNotEmpty ? state.user.name : state.user.email;
          print("user details: ${state.user.toString()}");
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text("Profile"),
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 32.sp, color: AppColors.white),
                  ),
                ),
                SizedBox(height: 16.h),
                CustomTextWidget(
                  text: displayName,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const Spacer(),
                CustomButton(

                  text: 'Logout',
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
