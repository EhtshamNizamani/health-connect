import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/presentation/screens/call_screen.dart';
import 'package:health_connect/features/chat/presentation/screens/incoming_call_widget.dart';
import 'package:health_connect/main.dart';

// This background handler MUST be a top-level function (outside of any class).
// This is required by the firebase_messaging package.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // It's recommended to initialize Firebase in the background handler as well.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // NOTE: You cannot perform UI navigation or show dialogs from here because
  // the app's UI is not active. This is where you would trigger a local notification.
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initializes all notification listeners.
  /// This should be called once when the app starts.
  Future<void> initializeListeners() async {
    // 1. Request permissions for iOS and newer Android versions
    await _firebaseMessaging.requestPermission();

    // 2. Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Listen for messages when the app is in the FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // 4. Listen for when the user TAPS a notification and the app opens from the BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // 5. Check if the app was opened from a TERMINATED state via a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("[NotificationService] App opened from terminated state by notification.");
      _handleMessage(initialMessage);
    }
  }

  /// Central handler for processing any incoming message.
  void _handleMessage(RemoteMessage message) {
    print('[NotificationService] Handling message with data: ${message.data}');
    
    // The actual data from our Cloud Function is inside the 'payload' key as a JSON string
    if (message.data.containsKey('payload')) {
      try {
        final payload = jsonDecode(message.data['payload']);

        // Check if it's our custom video call invitation
        if (payload['type'] == 'video_call_invitation') {
          print('[NotificationService] Received a video call invitation! Navigating...');

          // Use the global navigator key to show the IncomingCallScreen
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
          } else {
            print("[NotificationService] ERROR: Navigator state is null, cannot navigate to IncomingCallScreen.");
          }
        }
        // Handle call accepted notification
        else if (payload['type'] == 'call_accepted') {
          print('[NotificationService] Received call_accepted signal! Navigating to CallScreen.');
          
          // Get current user from AuthBloc
          final authState = sl<AuthBloc>().state;
          final currentUser = authState.user;
          final callId = payload['call_id'];
          
          if (currentUser != null && callId != null) {
            // Create otherUser from payload data
            final otherUser = UserEntity(
              id: payload['accepter_id'] ?? '',
              name: payload['accepter_name'] ?? 'Unknown User',
              photoUrl: payload['accepter_photo_url'] ?? '',
              email: '',
              role: payload['accepter_role'] ?? '',
            );

            // Navigate to CallScreen, replacing the CallingScreen
            final currentState = navigatorKey.currentState;
            if (currentState != null) {
              // First, try to pop any existing calling screen
              if (currentState.canPop()) {
                currentState.pop();
              }
              
              // Then navigate to the CallScreen
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
          } else {
            print("[NotificationService] ERROR: Missing required data for call_accepted navigation.");
          }
        }
        // You can add more 'else if' checks here for other notification types in the future
        // else if (payload['type'] == 'new_chat_message') { ... }

      } catch (e) {
        print("[NotificationService] ERROR: Failed to decode or handle notification payload: $e");
      }
    }
  }

  /// Retrieves the unique FCM token for this device.
  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print("====================================");
      print("Firebase Messaging Token: $token");
      print("====================================");
      return token;
    } catch (e) {
      print("Failed to get FCM token: $e");
      return null;
    }
  }
}