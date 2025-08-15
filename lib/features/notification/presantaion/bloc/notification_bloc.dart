import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_connect/core/services/sound_service.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/notification/domain/usecase/get_unread_count_usecase.dart';
import 'package:health_connect/features/notification/domain/usecase/mark_notification_as_read_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final MarkNotificationsAsReadUseCase _markNotificationsAsReadUseCase;
  final AuthBloc _authBloc;
final SoundService _soundService;
  StreamSubscription? _authSubscription;
  StreamSubscription? _countSubscription;

  NotificationBloc(
    this._getUnreadCountUseCase,
    this._markNotificationsAsReadUseCase,
    this._authBloc,
    this._soundService,
  ) : super(const NotificationState()) {
    // Register event handlers
    on<StartListeningToNotifications>(_onStartListening);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<MarkNotificationsAsRead>(_onMarkNotificationsAsRead);
    on<UnreadCountUpdated>(_onUnreadCountUpdated);
  }

  void _onStartListening(
    StartListeningToNotifications event,
    Emitter<NotificationState> emit,
  ) {
    print(
      "[NotificationBloc] 🚀 StartListeningToNotifications event received. Setting up listeners.",
    );

    // Cancel any existing subscriptions to avoid duplicates
    _authSubscription?.cancel();

    // 1. Immediately check the current state of AuthBloc
    final initialState = _authBloc.state;
    

    // Fire event for the current user, if they exist.
    // Thanks to LazySingleton, this state will be up-to-date.
    add(AuthUserChanged(initialState.user));

    // 2. Listen for any FUTURE auth state changes (e.g., logout)
    _authSubscription = _authBloc.stream
        .distinct((prev, next) {
          // Only fire if the user ID changes (from null to something, or vice versa)
          return prev.user?.id == next.user?.id;
        })
        .listen((authState) {
         
          add(AuthUserChanged(authState.user));
        });
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<NotificationState> emit,
  ) {
    // Always cancel the previous count subscription
    _countSubscription?.cancel();

    final user = event.user;

    if (user != null) {
      print(
        "[NotificationBloc] 👤 User is present (ID: ${user.id}). Subscribing to notifications.",
      );

      _countSubscription = _getUnreadCountUseCase(user.id, user.role).listen((
        result,
      ) {
        result.fold(
          (failure) => print(
            "[NotificationBloc] ❌ Error getting count: ${failure.message}",
          ),
          (count) {
            if (!isClosed) {
              // Safety check
              add(UnreadCountUpdated(count));
            }
          },
        );
      });
    } else {
    
      // Ensure the count is reset to 0
      emit(const NotificationState(unreadCount: 0));
    }
  }

  void _onUnreadCountUpdated(
    UnreadCountUpdated event,
    Emitter<NotificationState> emit,
  )async {
    if (event.newCount > state.unreadCount) {
    await _soundService.playNotificationSound(); 
    }
    if (state.unreadCount != event.newCount) {
      emit(state.copyWith(unreadCount: event.newCount));
    }
  }

  Future<void> _onMarkNotificationsAsRead(
    MarkNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final user = _authBloc.state.user;
    if (user == null) return;


    // Optimistically update the UI for a snappy feel
    emit(state.copyWith(unreadCount: 0));
    // Call the use case to update the database
    await _markNotificationsAsReadUseCase(
      MarkNotificationsAsReadParams(userId: user.id, role: user.role),
    );
  }

  @override
  Future<void> close() {
    print("[NotificationBloc] 🔌 Closing and cancelling all subscriptions.");
    _authSubscription?.cancel();
    _countSubscription?.cancel();
    return super.close();
  }
}
