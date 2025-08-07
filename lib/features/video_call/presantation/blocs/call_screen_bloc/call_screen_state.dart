
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CallScreenState extends Equatable {
  const CallScreenState();
  @override
  List<Object?> get props => [];
}

class CallScreenInitial extends CallScreenState {}

class CallScreenLoading extends CallScreenState {}

class CallScreenConnecting extends CallScreenState {}

class CallScreenConnected extends CallScreenState {
  final Widget? localView;
  final Widget? remoteView;
  final bool isCameraEnabled;
  final bool isMicEnabled;
  final bool isSpeakerEnabled;
  final bool showControls;
  final int callDurationSeconds;
  final String connectionStatus;

  const CallScreenConnected({
    this.localView,
    this.remoteView,
    required this.isCameraEnabled,
    required this.isMicEnabled,
    required this.isSpeakerEnabled,
    required this.showControls,
    required this.callDurationSeconds,
    required this.connectionStatus,
  });

  @override
  List<Object?> get props => [
        localView,
        remoteView,
        isCameraEnabled,
        isMicEnabled,
        isSpeakerEnabled,
        showControls,
        callDurationSeconds,
        connectionStatus,
      ];

  CallScreenConnected copyWith({
    Widget? localView,
    Widget? remoteView,
    bool? isCameraEnabled,
    bool? isMicEnabled,
    bool? isSpeakerEnabled,
    bool? showControls,
    int? callDurationSeconds,
    String? connectionStatus,
  }) {
    return CallScreenConnected(
      localView: localView ?? this.localView,
      remoteView: remoteView ?? this.remoteView,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isSpeakerEnabled: isSpeakerEnabled ?? this.isSpeakerEnabled,
      showControls: showControls ?? this.showControls,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}

class CallScreenError extends CallScreenState {
  final String message;
  const CallScreenError(this.message);
  @override
  List<Object> get props => [message];
}

class CallScreenEnded extends CallScreenState {}