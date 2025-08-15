part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [unreadCount, isLoading, errorMessage];
}