import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/shared/widgets/animated_badge_icon.dart'; 
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_state.dart';
import 'package:health_connect/features/notification/presantaion/bloc/notification_bloc.dart';

enum NotificationBadgeType {
  appointments,
  messages,
}

class NotificationBadgeIcon extends StatelessWidget {
  final IconData iconData;
  final double size;
  final NotificationBadgeType type;

  const NotificationBadgeIcon({
    super.key,
    required this.iconData,
    required this.size,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case NotificationBadgeType.appointments:
        return BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return _buildBadge(
              context: context,
              unreadCount: state.unreadCount,
            );
          },
        );
      case NotificationBadgeType.messages:
        return BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            int count = 0;
            if (state is ChatListLoaded) {
              count = state.totalUnreadCount;
            }
            return _buildBadge(
              context: context,
              unreadCount: count,
            );
          },
        );
    }
  }

  Widget _buildBadge({
    required BuildContext context,
    required int unreadCount,
  }) {
    return AnimatedBadgeIcon(
      triggerKey: unreadCount, 
      child: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          unreadCount > 99 ? '99+' : unreadCount.toString(),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        child: Icon(iconData, size: size),
      ),
    );
  }
}