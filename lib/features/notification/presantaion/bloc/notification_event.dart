part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}
class StartListeningToNotifications extends NotificationEvent {}

/// This event is triggered internally when the user logs in or out.
class AuthUserChanged extends NotificationEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);
}

/// Dispatched from the UI when the user views their notifications/appointments.
class MarkNotificationsAsRead extends NotificationEvent {}
class UnreadCountUpdated extends NotificationEvent {
  final int newCount;
  const UnreadCountUpdated(this.newCount);

  @override
  List<Object> get props => [newCount];
}