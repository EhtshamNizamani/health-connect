import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/utils/create_chat_room_id.dart';
import 'package:health_connect/core/utils/create_doctor_enitity.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_room_screen.dart';

void onOpenChat(BuildContext context, UserEntity patient) {
    final currentUser = context.read<AuthBloc>().state.user;
    if (currentUser == null) return;

    final chatRoomId = createChatRoomId(currentUser.id, patient.id);
    final doctorEntity = createDoctorEntity(currentUser);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatRoomId: chatRoomId,
          chatPartnerName: patient.name,
          receiverId: patient.id,
          doctor: doctorEntity,
          patient: patient,
        ),
      ),
    );
  }
