import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/doctor/appointment/presantation/screen/doctor_appointments_screen.dart';
import 'package:health_connect/features/patient/appointment/presentation/screen/patient_appointment_screen.dart';
import 'package:health_connect/features/video_call/presantation/screen/call_screen.dart';
import 'package:health_connect/features/video_call/presantation/screen/incoming_call_widget.dart';
import 'package:health_connect/main.dart';

// Track app state
bool isAppInForeground = true;

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isAppInForeground = (state == AppLifecycleState.resumed);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeListeners() async {
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());

    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages (no navigation here)
    FirebaseMessaging.onMessage.listen((message) {
      _handleMessage(message, fromNotificationTap: false);
    });

    // Notification taps from background/resume
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message, fromNotificationTap: true);
    });

    // App opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("[NotificationService] App opened from terminated state.");
      _handleMessage(initialMessage, fromNotificationTap: true);
    }
  }

  void _handleMessage(RemoteMessage message, {required bool fromNotificationTap}) {
    print('[NotificationService] Handling message with data: ${message.data}');

    if (!message.data.containsKey('payload')) return;

    try {
      final payload = jsonDecode(message.data['payload']);
      final messageType = payload['type'];

      switch (messageType) {
        case 'video_call_invitation':
          _handleIncomingCall(payload);
          break;
        case 'call_accepted':
          _handleCallAccepted(payload);
          break;
        case 'call_declined':
          _handleCallDeclined(payload);
          break;
        case 'call_ended':
          _handleCallEnded(payload);
          break;
        case 'call_cancelled':
          _handleCallCancelled(payload);
          break;

        case 'new_appointment':
          if (fromNotificationTap && !isAppInForeground) {
            _navigateIfNotCurrent(const DoctorAppointmentsScreen());
          } else {
            print("[NotificationService] Skipping navigation for new_appointment");
          }
          break;

        case 'appointment_status_update':
          if (fromNotificationTap && !isAppInForeground) {
            _navigateIfNotCurrent(const PatientAppointmentsScreen());
          } else {
            print("[NotificationService] Skipping navigation for appointment_status_update");
          }
          break;

        default:
          print('[NotificationService] Unknown message type: $messageType');
      }
    } catch (e) {
      print("[NotificationService] Error decoding payload: $e");
    }
  }

  void _navigateIfNotCurrent(Widget screen) {
    final currentState = navigatorKey.currentState;
    if (currentState == null) return;

    final currentRoute = ModalRoute.of(currentState.context)?.settings.name;
    final targetRoute = screen.runtimeType.toString();

    if (currentRoute != targetRoute) {
      currentState.push(MaterialPageRoute(builder: (_) => screen));
    } else {
      print("[NotificationService] Already on $targetRoute, skipping navigation.");
    }
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    print('[NotificationService] Received video call invitation');

    final currentState = navigatorKey.currentState;
    if (currentState != null) {
      currentState.push(
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(
            callId: payload['call_id'] ?? '',
            callerName: payload['caller_name'] ?? 'Unknown Caller',
            callerId: payload['caller_id'] ?? '',
            callerRole: payload['caller_role'] ?? '',
            callerPhotoUrl: payload['caller_photo_url'] ?? '',
          ),
        ),
      );
    }
  }

  void _handleCallAccepted(Map<String, dynamic> payload) {
    print('[NotificationService] Call accepted - navigating to CallScreen');

    final authState = sl<AuthBloc>().state;
    final currentUser = authState.user;
    final callId = payload['call_id'];

    if (currentUser != null && callId != null) {
      final otherUser = UserEntity(
        id: payload['accepter_id'] ?? '',
        name: payload['accepter_name'] ?? 'Unknown User',
        photoUrl: payload['accepter_photo_url'] ?? '',
        email: '',
        role: payload['accepter_role'] ?? '',
      );

      final currentState = navigatorKey.currentState;
      if (currentState != null) {
        if (currentState.canPop()) currentState.pop();
        currentState.push(
          MaterialPageRoute(
            builder: (_) => CallScreen(
              callID: callId,
              currentUser: currentUser,
              otherUser: otherUser,
            ),
          ),
        );
      }
    }
  }

  void _handleCallDeclined(Map<String, dynamic> payload) {
    print('[NotificationService] Call declined');

    final currentState = navigatorKey.currentState;
    if (currentState != null && currentState.canPop()) {
      currentState.pop();
      ScaffoldMessenger.of(currentState.context).showSnackBar(
        SnackBar(
          content: Text('${payload['decliner_name'] ?? 'User'} declined the call'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleCallEnded(Map<String, dynamic> payload) {
    print('[NotificationService] Call ended by other user');

    final currentState = navigatorKey.currentState;
    if (currentState != null) {
      if (currentState.canPop()) currentState.pop();
      ScaffoldMessenger.of(currentState.context).showSnackBar(
        SnackBar(
          content: Text('Call ended by ${payload['ender_name'] ?? 'other user'}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleCallCancelled(Map<String, dynamic> payload) {
    print('[NotificationService] Call cancelled by caller');

    final currentState = navigatorKey.currentState;
    if (currentState != null && currentState.canPop()) {
      currentState.pop();
      ScaffoldMessenger.of(currentState.context).showSnackBar(
        SnackBar(
          content: Text('${payload['caller_name'] ?? 'Caller'} cancelled the call'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print("Firebase Messaging Token: $token");
      return token;
    } catch (e) {
      print("Failed to get FCM token: $e");
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print("Subscribed to topic: $topic");
    } catch (e) {
      print("Failed to subscribe to topic: $e");
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print("Unsubscribed from topic: $topic");
    } catch (e) {
      print("Failed to unsubscribe from topic: $e");
    }
  }
}